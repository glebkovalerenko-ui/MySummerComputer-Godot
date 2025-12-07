extends ColorRect

@export var compatible_type: GlobalEnums.PartType = GlobalEnums.PartType.GPU

# Настройки жестов
const DRAG_THRESHOLD = 20.0
var _touch_start_pos: Vector2 = Vector2.ZERO
var _is_waiting_for_drag: bool = false

func _ready():
	color = Color(0.3, 0.3, 0.3)
	GameManager.pc_updated.connect(update_visual_state)
	update_visual_state()

func update_visual_state():
	var installed_item = GameManager.get_installed_part(compatible_type)
	
	# Очищаем старое
	for child in get_children():
		child.queue_free()
		
	if installed_item != null:
		var visual = ColorRect.new()
		visual.color = installed_item.color
		visual.set_anchors_preset(Control.PRESET_FULL_RECT)
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE # Чтобы события шли в Слот
		add_child(visual)

# --- ВВОД (CLICK + DRAG ИЗ СЛОТА) ---

func _gui_input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_touch_start_pos = event.global_position
			_is_waiting_for_drag = true
		elif not event.pressed and _is_waiting_for_drag:
			if _touch_start_pos.distance_to(event.global_position) < DRAG_THRESHOLD:
				_on_slot_clicked()
			_is_waiting_for_drag = false

func _on_slot_clicked():
	var installed_item = GameManager.get_installed_part(compatible_type)
	if installed_item:
		# Открываем инфо для УСТАНОВЛЕННОГО предмета
		UIManager.show_item_info(installed_item, GlobalEnums.ItemContext.INSTALLED)
	else:
		print("Slot is empty")
		# Здесь можно добавить логику подсветки инвентаря

func _get_drag_data(_at_position):
	var installed_item = GameManager.get_installed_part(compatible_type)
	if installed_item == null: return null
	
	# Проверка порога
	if _touch_start_pos.distance_to(get_global_mouse_position()) < DRAG_THRESHOLD:
		return null
		
	_is_waiting_for_drag = false
	
	# Данные для драга
	var preview = ColorRect.new()
	preview.size = size
	preview.color = installed_item.color
	preview.color.a = 0.5
	var c = Control.new()
	c.add_child(preview)
	preview.position = -0.5 * size
	set_drag_preview(c)
	
	return {
		"item_data": installed_item,
		"from_slot": true
	}

# --- DROP (ВСТАВКА) ---
func _can_drop_data(_at_position, data):
	if not data.has("item_data"): return false
	var item = data["item_data"] as ItemData
	if item.part_type != compatible_type: return false
	return GameManager.get_installed_part(compatible_type) == null

func _drop_data(_at_position, data):
	var item = data["item_data"] as ItemData
	GameManager.install_part(item)
