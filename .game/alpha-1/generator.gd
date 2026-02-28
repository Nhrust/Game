extends Node3D

# Ссылка на файл нашего кубика
var voxel_scene = preload("res://voxel.tscn")

# Размеры куска мира
const WIDTH = 20
const DEPTH = 20
const HEIGHT_SCALE = 5.0 # Насколько высокими будут холмы

func _ready():
	generate_map()

func generate_map():
	# Создаем генератор шума (как в Майнкрафте)
	var noise = FastNoiseLite.new()
	noise.seed = randi() # Каждый раз новый мир
	noise.frequency = 0.1 # Насколько "частые" будут холмы
	
	for x in range(WIDTH):
		for z in range(DEPTH):
			# Получаем значение высоты для этой точки (от -1 до 1)
			var noise_val = noise.get_noise_2d(x, z)
			# Превращаем это в количество кубиков по вертикали
			var current_height = int((noise_val + 1.0) * HEIGHT_SCALE)
			
			for y in range(current_height):
				create_voxel(x, y, z)

func create_voxel(x, y, z):
	var instance = voxel_scene.instantiate()
	add_child(instance)
	# Расставляем кубики в сетке 1x1x1
	instance.position = Vector3(x, y, z)
