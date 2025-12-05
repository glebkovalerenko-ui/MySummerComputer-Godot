extends ColorRect

@export var compatible_part_name: String = "GPU_Basic"

func _ready():
	color = Color.GRAY
	
	# Подписываемся на обновление ПК. 
	# Теперь слот сам проверяет, стоит в нем что-то или нет.
	GameManager.pc_updated.connect(update_visual_state)
	
	# Первая проверка при запуске
	update_visual_state()

# --- 1. РЕАКЦИЯ НА ИЗМЕНЕНИЯ (Reactive Logic) ---
func update_visual_state():
	# Проверяем в Менеджере: установлена ли эта деталь?
	var is_installed = compatible_part_name in GameManager.pc_assembled_parts
	
	if is_installed:
		# Если детали визуально нет — создаем
		if get_child_count() == 0:
			create_visual_part()
	else:
		# Если деталь визуально есть, но в базе её нет — удаляем
		for child in get_children():
			child.queue_free()

func create_visual_part():
	var inserted_part = ColorRect.new()
	inserted_part.color = Color.RED
	inserted_part.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Важно: игнорируем мышь на детали, чтобы слот под ней ловил события
	inserted_part.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(inserted_part)

# --- 2. ВСТАВКА (Принимаем деталь из инвентаря) ---
func _can_drop_data(_at_position, data):
	# Принимаем только если слот пуст и имя совпадает
	var is_empty = (compatible_part_name not in GameManager.pc_assembled_parts)
	return is_empty and data.get("part_name") == compatible_part_name

func _drop_data(_at_position, data):
	GameManager.install_part(data["part_name"])
	# Визуал обновится сам через update_visual_state (сигнал)

# --- 3. ИЗВЛЕЧЕНИЕ (Тянем деталь ИЗ слота) ---
func _get_drag_data(_at_position):
	print("Slot: Попытка тянуть слот...")
	# Если слот пуст, тянуть нечего
	if compatible_part_name not in GameManager.pc_assembled_parts:
		print("Slot: Пусто, тянуть нечего")
		return null
		
	print("Slot: Начало перетаскивания УСПЕХ")
	# 1. Формируем данные
	var data = {
		"part_name": compatible_part_name,
		"from_slot": true # Метка, что мы тянем уже установленную деталь
	}
	
	# 2. Визуальный призрак (Ghost)
	var preview = ColorRect.new()
	preview.size = size
	preview.color = Color.RED
	preview.color.a = 0.5
	var c = Control.new()
	c.add_child(preview)
	preview.position = -0.5 * size
	set_drag_preview(c)
	
	return data
