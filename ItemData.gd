extends Resource
class_name ItemData

# Уникальный ID (для сохранений и поиска), например "gpu_basic"
@export var id: String = ""

# Тип детали (для совместимости со слотами)
@export var part_type: GlobalEnums.PartType

# Отображаемое имя
@export var display_name: String = "Part Name"

# Цена в магазине
@export var price: int = 0

# Цвет для прототипа (замена текстуре)
@export var color: Color = Color.WHITE

# Здесь можно добавить icon: Texture2D, watts: int и т.д.
