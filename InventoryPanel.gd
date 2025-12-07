extends Control

# Путь к контейнеру изменится из-за добавления ScrollContainer
# Предполагаемая структура в сцене:
# Control -> ColorRect (BG) -> ScrollContainer -> HBoxContainer

@onready var container = $ColorRect/ScrollContainer/HBoxContainer
var item_scene = preload("res://ItemView.tscn")

func _ready():
	GameManager.inventory_updated.connect(_redraw_inventory)
	# Даем небольшую задержку, чтобы UI успел инициализироваться
	call_deferred("_redraw_inventory")

func _redraw_inventory():
	# Очистка
	for child in container.get_children():
		child.queue_free()
	
	# Заполнение
	for item_data in GameManager.inventory:
		var new_item = item_scene.instantiate()
		new_item.setup(item_data)
		container.add_child(new_item)
		
		# Настройка минимального размера, чтобы скролл работал корректно
		new_item.custom_minimum_size = Vector2(80, 80) 
		# (Или берем размер из самой сцены ItemView, если он там задан)
