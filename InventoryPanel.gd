extends Control

@onready var container = $ColorRect/HBoxContainer

# Загружаем шаблон предмета, чтобы создавать его копии
var item_scene = preload("res://ItemView.tscn")

func _ready():
	# Подписываемся на обновление данных
	GameManager.inventory_updated.connect(_redraw_inventory)
	
	# Рисуем инвентарь первый раз (вдруг там уже что-то есть)
	_redraw_inventory()

func _redraw_inventory():
	# 1. Очищаем текущее отображение (удаляем старые кнопки)
	for child in container.get_children():
		child.queue_free()
	
	# 2. Проходимся по массиву данных и создаем новые кнопки
	for item_name in GameManager.inventory:
		var new_item = item_scene.instantiate()
		
		# Настраиваем свойства (передаем имя в скрипт DraggableItem)
		new_item.part_name = item_name
		
		# (Опционально) Меняем цвет в зависимости от типа предмета
		if item_name == "GPU_Basic":
			new_item.color = Color.RED
		else:
			new_item.color = Color.BLUE
			
		# Добавляем в контейнер
		container.add_child(new_item)
