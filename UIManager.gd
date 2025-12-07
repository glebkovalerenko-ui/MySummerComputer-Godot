extends Node

# Прелоад сцены InfoPanel (Укажите верный путь после создания сцены!)
var info_panel_scene = preload("res://InfoPanel.tscn")

# Открыть информационное окно предмета
func show_item_info(item: ItemData, context: GlobalEnums.ItemContext):
	if info_panel_scene == null:
		printerr("UIManager: InfoPanel.tscn не назначен!")
		return
		
	# Создаем экземпляр окна
	var panel = info_panel_scene.instantiate()
	
	# Добавляем на текущую сцену (или в root, чтобы быть поверх всего)
	get_tree().root.add_child(panel)
	
	# Настраиваем данные
	panel.setup(item, context)
