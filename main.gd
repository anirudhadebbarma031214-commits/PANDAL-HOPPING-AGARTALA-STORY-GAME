extends Node3D

var player: CharacterBody3D
var camera: Camera3D
var speed := 5.0
var gravity := 18.0
var yaw := 0.0
var pitch := -12.0

func _ready():
	create_world()
	create_player()
	create_ui()

func create_world():
	# Sky
	var world_environment = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.025, 0.03, 0.05)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.6, 0.7)
	environment.ambient_light_energy = 0.7
	world_environment.environment = environment
	add_child(world_environment)

	# Sun
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

	# Ground
	create_box("Ground", Vector3(80, 0.2, 80), Vector3(0, -0.1, 0), Color(0.12, 0.16, 0.12))

	# Main roads
	create_box("Main Road", Vector3(12, 0.1, 80), Vector3(0, 0.05, 0), Color(0.055, 0.055, 0.06))
	create_box("Cross Road", Vector3(80, 0.1, 12), Vector3(0, 0.06, 0), Color(0.055, 0.055, 0.06))

	# Road markings
	for z in range(-35, 36, 7):
		create_box("RoadLine", Vector3(0.35, 0.03, 3.0), Vector3(0, 0.12, z), Color(0.9, 0.9, 0.75))

	for x in range(-35, 36, 7):
		create_box("RoadLine", Vector3(3.0, 0.03, 0.35), Vector3(x, 0.13, 0), Color(0.9, 0.9, 0.75))

	# Buildings
	create_building("BADHARGHAT HOME", Vector3(-18, 3, -16), Vector3(14, 6, 10), Color(0.55, 0.32, 0.22))
	create_building("ANI MALL", Vector3(22, 5, -17), Vector3(18, 10, 12), Color(0.20, 0.28, 0.42))
	create_building("TEA STALL", Vector3(-19, 1.5, 18), Vector3(8, 3, 6), Color(0.32, 0.20, 0.12))
	create_building("RESTAURANT", Vector3(18, 2.5, 18), Vector3(12, 5, 8), Color(0.42, 0.18, 0.12))
	create_building("RAILWAY STATION", Vector3(35, 4, 4), Vector3(14, 8, 18), Color(0.25, 0.27, 0.30))
	create_building("AIRPORT", Vector3(-35, 4, 5), Vector3(14, 8, 20), Color(0.30, 0.34, 0.38))

	# Trees
	for x in range(-35, 36, 10):
		for z in range(-35, 36, 12):
			if abs(x) > 7 and abs(z) > 7:
				create_tree(Vector3(x, 0, z))

	# Street lights
	for z in range(-30, 31, 10):
		create_street_light(Vector3(-7, 0, z))
		create_street_light(Vector3(7, 0, z))

func create_box(name: String, size: Vector3, pos: Vector3, color: Color):
	var body = StaticBody3D.new()
	body.name = name
	body.position = pos

	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box

	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	body.add_child(mesh)

	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	add_child(body)

func create_building(name: String, pos: Vector3, size: Vector3, color: Color):
	create_box(name, size, pos, color)

	# Windows
	for x in range(-2, 3):
		var window_pos = pos + Vector3(float(x) * 2.5, 0.5, size.z / 2.0 + 0.05)
		create_box("Window", Vector3(1.2, 1.5, 0.08), window_pos, Color(0.08, 0.18, 0.25))

func create_tree(pos: Vector3):
	var trunk = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.25
	cylinder.bottom_radius = 0.35
	cylinder.height = 2.5
	trunk.mesh = cylinder
	trunk.position = pos + Vector3(0, 1.25, 0)

	var trunk_mat = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.25, 0.12, 0.05)
	trunk.material_override = trunk_mat
	add_child(trunk)

	var leaves = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.7
	sphere.height = 3.4
	leaves.mesh = sphere
	leaves.position = pos + Vector3(0, 3.3, 0)

	var leaf_mat = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.08, 0.30, 0.12)
	leaves.material_override = leaf_mat
	add_child(leaves)

func create_street_light(pos: Vector3):
	create_box("Lamp Pole", Vector3(0.15, 4, 0.15), pos + Vector3(0, 2, 0), Color(0.15, 0.15, 0.17))
	create_box("Lamp", Vector3(0.7, 0.25, 0.7), pos + Vector3(0, 4.1, 0), Color(1.0, 0.8, 0.45))

func create_player():
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1.2, 8)
	add_child(player)

	var collision = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	collision.shape = capsule
	player.add_child(collision)

	var body_mesh = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.45
	capsule_mesh.height = 1.8
	body_mesh.mesh = capsule_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.12, 0.35, 0.75)
	body_mesh.material_override = material
	body_mesh.position.y = 0.9
	player.add_child(body_mesh)

	camera = Camera3D.new()
	camera.position = Vector3(0, 3.5, 6)
	camera.rotation_degrees = Vector3(pitch, 180, 0)
	camera.current = true
	player.add_child(camera)

func _physics_process(delta):
	if not player:
		return

	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input.x, 0, input.y)

	if direction.length() > 0:
		direction = direction.normalized()

		var movement = direction * speed
		player.velocity.x = movement.x
		player.velocity.z = movement.z
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed * 6 * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, speed * 6 * delta)

	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	else:
		player.velocity.y = 0

	player.move_and_slide()

	camera.look_at(player.global_position + Vector3(0, 1, 0), Vector3.UP)

func create_ui():
	var layer = CanvasLayer.new()
	add_child(layer)

	var title = Label.new()
	title.text = "PANDAL HOPPING"
	title.position = Vector2(25, 20)
	title.add_theme_font_size_override("font_size", 28)
	layer.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "AN AGARTALA STORY  •  A GAME BY ANI STUDIO"
	subtitle.position = Vector2(27, 55)
	subtitle.add_theme_font_size_override("font_size", 13)
	layer.add_child(subtitle)

	var mission = Label.new()
	mission.text = "MISSION 01\nTHE CALL FROM HOME\n\nExplore Agartala"
	mission.position = Vector2(25, 100)
	mission.add_theme_font_size_override("font_size", 18)
	layer.add_child(mission)

	var controls = Label.new()
	controls.text = "WASD / ARROW KEYS  •  MOVE"
	controls.position = Vector2(25, 650)
	controls.add_theme_font_size_override("font_size", 14)
	layer.add_child(controls)
