extends CanvasLayer

# Ссылки на ноды UI
@onready var title_label = $CenterContainer/Panel/VBox/TitleLabel
@onready var stats_label = $CenterContainer/Panel/VBox/StatsLabel
@onready var context_hint_label = $CenterContainer/Panel/VBox/ContextHintLabel
@onready var color_preview = $CenterContainer/Panel/VBox/ItemColorPreview
@onready var uninstall_button = $CenterContainer/Panel/VBox/ButtonsContainer/UninstallButton
@onready var close_button = $CenterContainer/Panel/VBox/ButtonsContainer/CloseButton
@onready var background = $Background

# Текущий предмет
var current_item: ItemData
var current_context: GlobalEnums.ItemContext

func _ready():
	close_button.pressed.connect(close)
	uninstall_button.pressed.connect(_on_uninstall_pressed)
	
	# Закрытие по клику на затемненный фон (через gui_input)
	background.gui_input.connect(_on_background_input)

# Метод инициализации окна
func setup(item: ItemData, context: GlobalEnums.ItemContext):
	current_item = item
	current_context = context
	
	# 1. Заполняем данные
	title_label.text = item.display_name
	color_preview.color = item.color
	
	var type_name = GlobalEnums.get_type_name(item.part_type)
	stats_label.text = "Тип: %s\nЦена: %d$" % [type_name, item.price]
	
	# 2. Логика кнопок и подсказок в зависимости от контекста
	match context:
		GlobalEnums.ItemContext.INVENTORY:
			uninstall_button.visible = false
			context_hint_label.text = "(Перетащи деталь на ПК, чтобы установить)"
			context_hint_label.modulate = Color.YELLOW
			
		GlobalEnums.ItemContext.INSTALLED:
			uninstall_button.visible = true
			context_hint_label.text = "Деталь установлена в систему."
			context_hint_label.modulate = Color.GREEN
			
		GlobalEnums.ItemContext.SHOP:
			uninstall_button.visible = false
			context_hint_label.text = "Товар в магазине."

	# Показываем окно
	visible = true

func _on_uninstall_pressed():
	if current_item and current_context == GlobalEnums.ItemContext.INSTALLED:
		GameManager.uninstall_part(current_item)
		close()

func _on_background_input(event):
	if event is InputEventMouseButton and event.pressed:
		close()

func close():
	queue_free() # Уничтожаем окно при закрытии
