extends CharacterBody3D

# --- НАСТРОЙКИ ---
const SPEED_NORMAL = 5.0
const SPEED_SNEAK = 2.0
const SPEED_SPRINT = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

# Гравитация из настроек проекта
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D

func _ready():
	# Скрываем мышку
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Вращение головой
	if event is InputEventMouseMotion:
		# Вращаем всё тело влево-вправо (Y)
		rotate_y(-event.relative.x * SENSITIVITY)
		# Вращаем только камеру вверх-вниз (X)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		# Ограничиваем наклон, чтобы не перевернуться
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta):
	# Применяем гравитацию
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Прыжок
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Выбор скорости (Твоя логика: Shift - медленно, Ctrl - быстро)
	var current_speed = SPEED_NORMAL
	if Input.is_action_pressed("sprint"):
		current_speed = SPEED_SPRINT
	elif Input.is_action_pressed("sneak"):
		current_speed = SPEED_SNEAK

	# Получаем направление движения
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# СЧИТАЕМ НАПРАВЛЕНИЕ: 
	# Используем transform.basis (тело), а не camera.basis, чтобы НЕ ЛЕТАТЬ
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		# Плавная остановка
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# Запуск физики
	move_and_slide()
