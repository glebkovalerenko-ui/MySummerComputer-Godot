extends ColorRect

# Настраиваем в Инспекторе: Какой тип принимает этот слот?
@export var compatible_type: GlobalEnums.PartType = GlobalEnums.PartType.GPU

func _ready():
	color = Color(0.3, 0.3, 0.3) # Серый цвет пустого слота
	GameManager.pc_updated.connect(update_visual_state)
	update_visual_state()

# --- 1. РЕАКЦИЯ НА ИЗМЕНЕНИЯ ---
func update_visual_state():
	# Ищем в менеджере деталь нужного нам типа
	var installed_item = GameManager.get_installed_part(compatible_type)
	
	if installed_item != null:
		# Если деталь есть в базе, но нет визуально -> создаем
		if get_child_count() == 0:
			create_visual_part(installed_item)
		else:
			# Если визуально что-то есть, проверим, та ли это деталь
			# (вдруг мы поменяли одну GPU на другую)
			# Для простоты: просто пересоздаем, если цвет не совпал (или ID)
			pass 
	else:
		# Если в базе пусто, а визуально что-то есть -> удаляем
		for child in get_children():
			child.queue_free()

func create_visual_part(item: ItemData):
	var inserted_part = ColorRect.new()
	inserted_part.color = item.color # Берем цвет из Ресурса
	inserted_part.set_anchors_preset(Control.PRESET_FULL_RECT)
	inserted_part.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(inserted_part)

# --- 2. ВСТАВКА (DROP) ---
func _can_drop_data(_at_position, data):
	# Проверяем структуру данных
	if not data.has("item_data"): return false
	
	var item = data["item_data"] as ItemData
	
	# 1. Проверяем тип (GPU == GPU?)
	if item.part_type != compatible_type:
		return false
		
	# 2. Проверяем, не занят ли слот
	var is_occupied = (GameManager.get_installed_part(compatible_type) != null)
	return not is_occupied

func _drop_data(_at_position, data):
	var item = data["item_data"] as ItemData
	GameManager.install_part(item)

# --- 3. ИЗВЛЕЧЕНИЕ (DRAG) ---
func _get_drag_data(_at_position):
	# Проверяем, есть ли что-то в этом слоте
	var installed_item = GameManager.get_installed_part(compatible_type)
	
	if installed_item == null:
		return null
		
	print("Slot: Тянем ", installed_item.display_name)
	
	var data = {
		"item_data": installed_item,
		"from_slot": true # Метка, что тянем из ПК
	}
	
	# Визуальный призрак
	var preview = ColorRect.new()
	preview.size = size
	preview.color = installed_item.color
	preview.color.a = 0.5
	var c = Control.new()
	c.add_child(preview)
	preview.position = -0.5 * size
	set_drag_preview(c)
	
	return data
