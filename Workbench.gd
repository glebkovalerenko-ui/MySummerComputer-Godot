extends Control

@onready var money_label = $MoneyLabel
@onready var buy_button = $BuyGpuButton

# СЮДА перетащить GPU_Basic.tres в Инспекторе!
@export var gpu_item_to_sell: ItemData 

func _ready():
	update_ui()
	check_button_state()
	
	GameManager.money_updated.connect(update_ui)
	GameManager.inventory_updated.connect(check_button_state)
	GameManager.pc_updated.connect(check_button_state)
	
	$ToWorkButton.pressed.connect(_on_to_work_pressed)
	$BuyGpuButton.pressed.connect(_on_buy_gpu_pressed)

func update_ui():
	money_label.text = "Деньги: %d$" % GameManager.money

func check_button_state():
	if gpu_item_to_sell == null:
		buy_button.text = "ERROR: No Item Data"
		buy_button.disabled = true
		return

	# Проверяем наличие GPU любого вида (упрощенная логика)
	# Или конкретно этого GPU. Давайте проверим наличие ТИПА GPU.
	
	var has_gpu_installed = GameManager.get_installed_part(GlobalEnums.PartType.GPU) != null
	
	# Также проверим, есть ли этот конкретный предмет в инвентаре (чтобы не покупать бесконечно)
	var has_in_inventory = gpu_item_to_sell in GameManager.inventory
	
	var has_gpu = has_gpu_installed or has_in_inventory
	
	buy_button.disabled = has_gpu
	if has_gpu:
		buy_button.text = "Куплено / Установлено"
	else:
		buy_button.text = "Купить %s (%d$)" % [gpu_item_to_sell.display_name, gpu_item_to_sell.price]

func _on_buy_gpu_pressed():
	if gpu_item_to_sell == null: return
	
	if GameManager.money >= gpu_item_to_sell.price:
		GameManager.change_money(-gpu_item_to_sell.price)
		GameManager.add_item(gpu_item_to_sell)

func _on_to_work_pressed():
	get_tree().change_scene_to_file("res://WorkRoom.tscn")

# --- СНЯТИЕ ДЕТАЛИ (UNINSTALL) ---

func _can_drop_data(_at_position, data):
	# Разрешаем бросать, только если тянут ИЗ слота
	if typeof(data) == TYPE_DICTIONARY and data.get("from_slot") == true:
		return true
	return false

func _drop_data(_at_position, data):
	var item = data["item_data"] as ItemData
	GameManager.uninstall_part(item)
