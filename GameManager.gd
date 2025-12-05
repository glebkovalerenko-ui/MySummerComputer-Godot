extends Node

# --- СИГНАЛЫ ---
signal inventory_updated
signal pc_updated
signal money_updated

# --- ДАННЫЕ (State) ---
var money: int = 200 # Подкинул немного денег для тестов
var energy: int = 100

# Инвентарь теперь хранит ссылки на ресурсы ItemData
var inventory: Array[ItemData] = []

# Собранный ПК тоже хранит ресурсы.
# Для простоты пока оставляем массив, но ищем в нем по типу.
var pc_assembled_parts: Array[ItemData] = []

# --- УПРАВЛЕНИЕ ИНВЕНТАРЕМ ---

func add_item(item: ItemData):
	if item == null: return
	inventory.append(item)
	inventory_updated.emit()
	print("Inventory add: ", item.display_name)

func remove_item(item: ItemData):
	if item in inventory:
		# Удаляем конкретный экземпляр ссылки (или первую найденную)
		inventory.erase(item)
		inventory_updated.emit()
		print("Inventory remove: ", item.display_name)

# --- УПРАВЛЕНИЕ СБОРКОЙ ---

func install_part(item: ItemData):
	if item in inventory:
		remove_item(item) # Убрать из инвентаря
		pc_assembled_parts.append(item)
		pc_updated.emit()
		print("PC Install: ", item.display_name)

func uninstall_part(item: ItemData):
	if item in pc_assembled_parts:
		pc_assembled_parts.erase(item)
		pc_updated.emit()
		add_item(item) # Вернуть в инвентарь
		print("PC Uninstall: ", item.display_name)

# Вспомогательная функция: Получить установленную деталь определенного типа
func get_installed_part(type: GlobalEnums.PartType) -> ItemData:
	for part in pc_assembled_parts:
		if part.part_type == type:
			return part
	return null

# --- ФИНАНСЫ ---
func change_money(amount: int):
	money += amount
	money_updated.emit()
