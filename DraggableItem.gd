extends ColorRect

# Храним не строку, а сам ресурс данных
var item_data: ItemData

func setup(data: ItemData):
	item_data = data
	color = data.color
	# Здесь можно добавить загрузку иконки:
	# $Icon.texture = data.icon 
	# tooltip_text = "%s\n$%d" % [data.display_name, data.price]

func _get_drag_data(_at_position):
	if item_data == null: return null
	
	# 1. Данные для передачи
	var data = {
		"item_data": item_data, # Передаем весь ресурс целиком
		"origin_node": self
	}
	
	# 2. Визуализация (Ghost)
	var preview = ColorRect.new()
	preview.size = size
	preview.color = color
	preview.color.a = 0.5
	
	var preview_control = Control.new()
	preview_control.add_child(preview)
	preview.position = -0.5 * size 
	
	set_drag_preview(preview_control)
	
	return data
