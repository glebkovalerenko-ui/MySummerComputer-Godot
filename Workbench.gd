extends Control

@onready var money_label = $MoneyLabel
@onready var buy_button = $BuyGpuButton

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
	var has_gpu = ("GPU_Basic" in GameManager.inventory) or ("GPU_Basic" in GameManager.pc_assembled_parts)
	buy_button.disabled = has_gpu
	buy_button.text = "Куплено / Установлено" if has_gpu else "Купить GPU (100$)"

func _on_buy_gpu_pressed():
	if GameManager.money >= 100:
		GameManager.change_money(-100)
		GameManager.add_item("GPU_Basic")

func _on_to_work_pressed():
	get_tree().change_scene_to_file("res://WorkRoom.tscn")

# --- НОВАЯ ЛОГИКА: СНЯТИЕ ДЕТАЛИ (UNINSTALL) ---

func _can_drop_data(_at_position, data):
	# Мы разрешаем бросать сюда, ТОЛЬКО если деталь тянут из слота.
	# (Если тянуть из инвентаря на стол — ничего не произойдет)
	if typeof(data) == TYPE_DICTIONARY and data.get("from_slot") == true:
		return true
	return false

func _drop_data(_at_position, data):
	print("Workbench: DROP ПОЙМАН!")
	# Если игрок бросил деталь на стол — снимаем её
	GameManager.uninstall_part(data["part_name"])
	
	# Пояснение:
	# 1. Мы вызвали uninstall_part
	# 2. GameManager убрал деталь из массива pc_assembled_parts
	# 3. GameManager испустил сигнал pc_updated
	# 4. Slot.gd поймал сигнал -> увидел, что детали нет -> удалил красный квадрат
	# 5. GameManager испустил сигнал inventory_updated
	# 6. InventoryPanel поймала сигнал -> отрисовала синий квадрат внизу
