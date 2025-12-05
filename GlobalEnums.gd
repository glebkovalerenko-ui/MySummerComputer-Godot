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

# Вспомогательная функция для получения названия типа (для отладки)
static func get_type_name(type: PartType) -> String:
	return PartType.keys()[type]
