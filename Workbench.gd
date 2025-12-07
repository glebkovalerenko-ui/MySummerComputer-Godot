extends Control

# Ссылки на элементы интерфейса с учетом новой вложенности (SafeZone -> GameSpace)
@onready var money_label = $SafeZone/GameSpace/MoneyLabel
@onready var buy_button = $SafeZone/GameSpace/BuyGpuButton

# СЮДА перетащить GPU_Basic.tres в Инспекторе!
@export var gpu_item_to_sell: ItemData 

func _ready():
	update_ui()
	check_button_state()
	
	# Подключаем сигналы от менеджера игры
	GameManager.money_updated.connect(update_ui)
	GameManager.inventory_updated.connect(check_button_state)
	GameManager.pc_updated.connect(check_button_state)
	
	# Подключаем сигналы нажатия кнопок (пути обновлены)
	$SafeZone/GameSpace/ToWorkButton.pressed.connect(_on_to_work_pressed)
	$SafeZone/GameSpace/BuyGpuButton.pressed.connect(_on_buy_gpu_pressed)

func update_ui():
	# Обновляем текст метки денег
	money_label.text = "Деньги: %d$" % GameManager.money

func check_button_state():
	# Если забыли назначить предмет в инспекторе
	if gpu_item_to_sell == null:
		buy_button.text = "ERROR: No Item Data"
		buy_button.disabled = true
		return

	# Проверяем, установлена ли уже видеокарта в ПК
	var has_gpu_installed = GameManager.get_installed_part(GlobalEnums.PartType.GPU) != null
	
	# Проверяем, есть ли эта видеокарта в инвентаре
	var has_in_inventory = gpu_item_to_sell in GameManager.inventory
	
	var has_gpu = has_gpu_installed or has_in_inventory
	
	# Блокируем кнопку, если карта уже есть (куплена или стоит в ПК)
	buy_button.disabled = has_gpu
	
	if has_gpu:
		buy_button.text = "Куплено / Установлено"
	else:
		buy_button.text = "Купить %s (%d$)" % [gpu_item_to_sell.display_name, gpu_item_to_sell.price]

func _on_buy_gpu_pressed():
	if gpu_item_to_sell == null: return
	
	# Логика покупки
	if GameManager.money >= gpu_item_to_sell.price:
		GameManager.change_money(-gpu_item_to_sell.price)
		GameManager.add_item(gpu_item_to_sell)

func _on_to_work_pressed():
	# Переход в комнату работы
	get_tree().change_scene_to_file("res://WorkRoom.tscn")

# --- СНЯТИЕ ДЕТАЛИ (UNINSTALL) ---

func _can_drop_data(_at_position, data):
	# Разрешаем бросать деталь на фон верстака, ТОЛЬКО если мы тянем её ИЗ слота ПК.
	# Если тянем из инвентаря на фон — ничего не происходит (отмена).
	if typeof(data) == TYPE_DICTIONARY and data.get("from_slot") == true:
		return true
	return false

func _drop_data(_at_position, data):
	# Если бросили деталь на фон — снимаем её с ПК и возвращаем в инвентарь
	var item = data["item_data"] as ItemData
	GameManager.uninstall_part(item)
