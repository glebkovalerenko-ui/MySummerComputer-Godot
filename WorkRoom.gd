extends Control

# Ссылки на элементы интерфейса (чтобы менять текст и отключать кнопки)
@onready var info_label = $InfoLabel
@onready var work_button = $WorkButton

func _ready():
	# При запуске сцены сразу обновляем текст, чтобы показать актуальные деньги
	update_ui()
	
	# Подключаем сигналы кнопок через код (это надежнее и чище)
	$WorkButton.pressed.connect(_on_work_button_pressed)
	$HomeButton.pressed.connect(_on_home_button_pressed)

func update_ui():
	# Берем данные из нашего глобального GameManager
	info_label.text = "Деньги: %d$ | Энергия: %d" % [GameManager.money, GameManager.energy]

func _on_work_button_pressed():
	if GameManager.energy >= 10:
		# 1. Списываем энергию сразу
		GameManager.energy -= 10
		update_ui()
		
		# 2. Блокируем кнопку, чтобы нельзя было спамить
		work_button.disabled = true
		work_button.text = "Работаю..."
		
		# 3. Ждем 2 секунды (создаем таймер на лету)
		# await - это ожидание завершения асинхронного действия
		await get_tree().create_timer(2.0).timeout
		
		# 4. Начисляем зарплату
		GameManager.money += 100
		
		# 5. Возвращаем кнопку в исходное состояние
		work_button.disabled = false
		work_button.text = "РАБОТАТЬ (2 сек)"
		update_ui()
	else:
		info_label.text = "Не хватает энергии! Нужно поспать (пока не реализовано)"
		# Можно добавить мигание красным, но пока хватит текста

func _on_home_button_pressed():
	# Переключаемся обратно на сцену верстака
	get_tree().change_scene_to_file("res://Workbench.tscn")
