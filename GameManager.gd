extends Node

# --- СИГНАЛЫ ---
# Испускаются, когда данные меняются. UI будет их слушать.
signal inventory_updated # Инвентарь изменился (добавили/убрали вещь)
signal pc_updated        # Состояние сборки изменилось (деталь поставили/сняли)
signal money_updated     # Денег стало больше/меньше

# --- ДАННЫЕ (State) ---
var money: int = 100
var energy: int = 100

# Массивы теперь меняем только через функции ниже
var inventory: Array[String] = []
var pc_assembled_parts: Array[String] = []

# --- ФУНКЦИИ УПРАВЛЕНИЯ ИНВЕНТАРЕМ ---

# Добавить предмет в инвентарь (покупка или снятие с ПК)
func add_item(item_name: String):
	inventory.append(item_name)
	inventory_updated.emit() # Сообщаем всем: "Перерисуйте инвентарь!"
	print("Inventory add: ", item_name, " | Total: ", inventory)

# Удалить предмет из инвентаря (продажа или установка в ПК)
func remove_item(item_name: String):
	if item_name in inventory:
		inventory.erase(item_name) # Удаляет первое совпадение
		inventory_updated.emit()
		print("Inventory remove: ", item_name)

# --- ФУНКЦИИ УПРАВЛЕНИЯ СБОРКОЙ ---

# Установка детали: Из инвентаря -> В ПК
func install_part(part_name: String):
	# Сначала проверяем, есть ли деталь в инвентаре
	if part_name in inventory:
		remove_item(part_name) # Убираем из инвентаря (сигнал inventory_updated сработает внутри)
		pc_assembled_parts.append(part_name)
		pc_updated.emit()      # Сообщаем слотам: "Проверьте свое состояние"
		print("PC Install: ", part_name)

# Снятие детали: Из ПК -> В инвентарь
func uninstall_part(part_name: String):
	if part_name in pc_assembled_parts:
		pc_assembled_parts.erase(part_name)
		pc_updated.emit()      # Сообщаем слотам
		add_item(part_name)    # Возвращаем в инвентарь (сигнал inventory_updated сработает внутри)
		print("PC Uninstall: ", part_name)

# --- ФИНАНСЫ ---
func change_money(amount: int):
	money += amount
	money_updated.emit()
