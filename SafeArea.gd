extends MarginContainer

# Скрипт автоматически обновляет отступы (Margins) контейнера,
# чтобы UI не перекрывался вырезами экрана (Notch/Dynamic Island).

func _ready():
	# Обновляем сразу при старте
	_update_safe_area()
	
	# Подписываемся на изменение размера окна (поворот экрана)
	get_tree().root.size_changed.connect(_update_safe_area)

func _update_safe_area():
	# Получаем безопасную зону от ОС (в пикселях экрана)
	var safe_area = DisplayServer.get_display_safe_area()
	var window_size = DisplayServer.window_get_size()
	
	# Рассчитываем отступы
	# Safe Area возвращает Rect2i координат. Нам нужно превратить их в отступы.
	
	var margin_left = safe_area.position.x
	var margin_top = safe_area.position.y
	var margin_right = window_size.x - safe_area.end.x
	var margin_bottom = window_size.y - safe_area.end.y
	
	# Применяем отступы к MarginContainer
	# Добавляем минимальные отступы (например 10px), чтобы контент не лип к краям даже на ровных экранах
	add_theme_constant_override("margin_left", margin_left + 10)
	add_theme_constant_override("margin_top", margin_top + 10)
	add_theme_constant_override("margin_right", margin_right + 10)
	add_theme_constant_override("margin_bottom", margin_bottom + 10)
