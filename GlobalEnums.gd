class_name GlobalEnums

# Перечисление всех возможных типов деталей
enum PartType {
	GPU,
	CPU,
	RAM,
	MOTHERBOARD,
	COOLER,
	PSU,
	CASE
}

# Контекст, в котором находится предмет (для UI)
enum ItemContext {
	INVENTORY, # Предмет лежит в инвентаре
	INSTALLED, # Предмет установлен в слот ПК
	SHOP       # Предмет в магазине (на будущее)
}

# Вспомогательная функция для получения названия типа
static func get_type_name(type: PartType) -> String:
	return PartType.keys()[type]
