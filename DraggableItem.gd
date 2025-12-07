extends ColorRect

# Храним данные
var item_data: ItemData

# Настройки жестов
const DRAG_THRESHOLD = 20.0 # Пикселей для начала драга

# Переменные состояния ввода
var _touch_start_pos: Vector2 = Vector2.ZERO
var _is_waiting_for_drag: bool = false

func setup(data: ItemData):
	item_data = data
	color = data.color
	# tooltip_text удален, так как на мобильных нет ховера

# --- SMART INPUT IMPLEMENTATION ---

func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			# 1. Палец нажат: запоминаем позицию
			_touch_start_pos = event.global_position
			_is_waiting_for_drag = true
			
		elif not event.pressed and _is_waiting_for_drag:
			# 2. Палец отпущен: проверяем, был ли это клик
			var distance = _touch_start_pos.distance_to(event.global_position)
			
			if distance < DRAG_THRESHOLD:
				# Это КЛИК (палец почти не сдвинулся)
				_on_click()
			
			_is_waiting_for_drag = false

func _get_drag_data(_at_position):
	if item_data == null: return null
	
	# 3. Проверка порога для Drag&Drop
	# Godot вызывает этот метод, когда считает, что начался драг.
	# Мы дополнительно проверяем дистанцию, чтобы исключить случайные срывы.
	
	var current_pos = get_global_mouse_position()
	if _touch_start_pos.distance_to(current_pos) < DRAG_THRESHOLD:
		return null # Запрещаем драг, если не прошли порог
		
	# Если прошли порог - начинаем перетаскивание
	_is_waiting_for_drag = false # Отменяем ожидание клика
	
	# Визуализация (Ghost)
	var preview = ColorRect.new()
	preview.size = size
	preview.color = color
	preview.color.a = 0.5
	
	var preview_control = Control.new()
	preview_control.add_child(preview)
	preview.position = -0.5 * size 
	
	set_drag_preview(preview_control)
	
	# Данные
	return {
		"item_data": item_data,
		"origin_node": self
	}

func _on_click():
	print("Item Clicked: ", item_data.display_name)
	# Вызываем UIManager (предполагаем, что он в Autoload)
	# Если UIManager не в Autoload, замените на GameManager.ui_manager.show_item_info(...)
	UIManager.show_item_info(item_data, GlobalEnums.ItemContext.INVENTORY)
