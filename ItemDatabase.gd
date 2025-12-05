extends Node

# Словарь: "id_предмета" -> Ресурс(ItemData)
var all_items: Dictionary = {}

func _ready():
	_scan_resources("res://Resources/Parts/")

# Рекурсивное сканирование папки на наличие .tres файлов
func _scan_resources(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Если это папка, заходим внутрь (рекурсия)
				if file_name != "." and file_name != "..":
					_scan_resources(path + "/" + file_name)
			else:
				# Если это файл ресурса (.tres или .remap для экспорта)
				if file_name.ends_with(".tres") or file_name.ends_with(".remap"):
					# Убираем .remap, если запускаем в собранной игре
					var clean_name = file_name.replace(".remap", "")
					var full_path = path + "/" + clean_name
					
					var resource = load(full_path)
					if resource is ItemData:
						if resource.id == "":
							printerr("ОШИБКА: У предмета нет ID! Путь: ", full_path)
						else:
							all_items[resource.id] = resource
							print("DB Loaded: ", resource.id, " -> ", resource.display_name)
			
			file_name = dir.get_next()
	else:
		printerr("ОШИБКА: Не удалось открыть папку ", path)

# Получить предмет по ID
func get_item_by_id(id: String) -> ItemData:
	if id in all_items:
		return all_items[id]
	return null
