extends ColorRect

# Имя детали, которое мы передадим слоту
@export var part_name: String = "GPU_Basic"

func _get_drag_data(_at_position):
	# 1. Создаем данные, которые "летут" вместе с курсором
	var data = {
		"part_name": part_name,
		"origin_node": self # Ссылка на саму себя, чтобы потом можно было удалить/скрыть
	}
	
	# 2. Визуализация перетаскивания (Ghost)
	# Мы создаем копию этого квадрата, которая прилипнет к курсору
	var preview = ColorRect.new()
	preview.size = size
	preview.color = color
	preview.color.a = 0.5 # Делаем полупрозрачным
	
	# Control узел, который будет держать превью
	var preview_control = Control.new()
	preview_control.add_child(preview)
	# Смещаем, чтобы курсор был по центру детали
	preview.position = -0.5 * size 
	
	# Эта функция встроенная, она "вешает" превью на курсор
	set_drag_preview(preview_control)
	
	return data
