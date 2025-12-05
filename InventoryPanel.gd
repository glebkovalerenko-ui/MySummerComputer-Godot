extends Control

@onready var container = $ColorRect/HBoxContainer
var item_scene = preload("res://ItemView.tscn")

func _ready():
	GameManager.inventory_updated.connect(_redraw_inventory)
	_redraw_inventory()

func _redraw_inventory():
	for child in container.get_children():
		child.queue_free()
	
	for item_data in GameManager.inventory:
		var new_item = item_scene.instantiate()
		
		# Передаем ВЕСЬ ресурс в DraggableItem.gd
		new_item.setup(item_data)
		
		container.add_child(new_item)
