extends Node3D

const NAMES := ["JAY — THE DRIVER", "RAFE — THE FIXER", "MIRA — THE TECH EXPERT"]
const COLORS := [Color(0.05, 0.78, 0.86), Color(0.94, 0.57, 0.18), Color(0.88, 0.24, 0.52)]
const PICKUP := Vector3(-16, 0, -15)
const DELIVERY := Vector3(42, 0, 16)
const SAFEHOUSE := Vector3(-19, 0, 21)
const STORE := Vector3(-33, 0, -11)
const MALL := Vector3(33, 0, 17)

var players: Array[CharacterBody3D] = []
var vehicles: Array[Node3D] = []
var npcs: Array[Node3D] = []
var active := 0
var driving := false
var active_vehicle: Node3D
var mission_stage := 0
var cash := 2450
var elapsed := 0.0
var marker: Node3D
var camera: Camera3D
var mission_label: Label
var objective_label: Label
var status_label: Label
var toast_label: Label
var progress_bar: ProgressBar
var toast_time := 0.0

func _ready() -> void:
	_setup_input()
	_build_lighting()
	_build_world()
	_build_players()
	_build_vehicles()
	_build_npcs()
	_build_marker()
	_build_hud()
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 70.0
	add_child(camera)
	_update_camera(1.0)
	_toast("WELCOME TO AGARTALA — STORY MISSION 01")

func _setup_input() -> void:
	var actions := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "interact": KEY_E, "sprint": KEY_SHIFT, "switch_1": KEY_1, "switch_2": KEY_2, "switch_3": KEY_3, "mission_info": KEY_M}
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = actions[action]
		InputMap.action_add_event(action, ev)

func _build_lighting() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.10, 0.24, 0.40)
	sky_mat.sky_horizon_color = Color(0.88, 0.64, 0.42)
	sky_mat.ground_bottom_color = Color(0.12, 0.16, 0.14)
	sky_mat.ground_horizon_color = Color(0.55, 0.48, 0.39)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.70, 0.79)
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.66, 0.72, 0.75)
	env.fog_density = 0.0018
	env_node.environment = env
	add_child(env_node)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -28, 0)
	sun.light_color = Color(1.0, 0.78, 0.58)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	add_child(sun)

func _build_world() -> void:
	_box("Town ground", Vector3(260, 1, 260), Vector3(0, -0.7, 0), Color(0.20, 0.31, 0.23), true)
	_box("Main street", Vector3(12, 0.12, 210), Vector3(0, -0.08, 0), Color(0.12, 0.14, 0.16))
	_box("Market road", Vector3(180, 0.12, 10), Vector3(0, -0.07, 0), Color(0.13, 0.15, 0.17))
	_box("Residential lane", Vector3(7, 0.12, 100), Vector3(-25, -0.06, 0), Color(0.16, 0.17, 0.18))
	_box("Northeast highway", Vector3(22, 0.14, 240), Vector3(64, -0.04, 8), Color(0.10, 0.12, 0.14))
	for z in range(-95, 100, 10):
		_box("Road dash", Vector3(0.22, 0.025, 4.2), Vector3(0, 0.01, z), Color(0.92, 0.82, 0.59))
		_box("Highway dash", Vector3(0.22, 0.03, 5), Vector3(64, 0.04, z), Color(0.94, 0.88, 0.70))
	for x in range(-80, 85, 10):
		_box("Market dash", Vector3(4.4, 0.025, 0.18), Vector3(x, 0.01, 0), Color(0.92, 0.82, 0.59))
	_box("Pond bank", Vector3(28, 0.35, 23), Vector3(-42, -0.28, 33), Color(0.37, 0.34, 0.23))
	_box("Village pond", Vector3(24, 0.12, 19), Vector3(-42, -0.08, 33), Color(0.10, 0.37, 0.43))
	for i in range(5):
		_box("Pond ghat step", Vector3(6.0 - i * 0.6, 0.22, 1.0), Vector3(-42, -0.02 + i * 0.06, 21 + i), Color(0.55, 0.53, 0.45))
	_building("Maa's Kitchen", Vector3(-16, 4, -15), Vector3(12, 8, 12), Color(0.78, 0.60, 0.42))
	_building("Tripura General Store", Vector3(-33, 3.2, -11), Vector3(9, 6.4, 10), Color(0.80, 0.72, 0.51))
	_building("Food Corner", Vector3(20, 5, -20), Vector3(14, 10, 12), Color(0.76, 0.43, 0.30))
	_building("Jay's Safe House", SAFEHOUSE, Vector3(12, 8, 12), Color(0.78, 0.71, 0.57))
	_building("City Mall", Vector3(33, 6, 17), Vector3(18, 12, 14), Color(0.54, 0.62, 0.67))
	_building("Highway Dhaba", Vector3(47, 4, -19), Vector3(10, 8, 11), Color(0.72, 0.53, 0.35))
	_building("Tea and Puchka", Vector3(-52, 3, -10), Vector3(12, 6, 11), Color(0.70, 0.47, 0.36))
	_building("Bike Repair", Vector3(16, 3.8, 17), Vector3(10, 7.6, 10), Color(0.65, 0.71, 0.54))
	_box("Kitchen awning", Vector3(8, 0.45, 1.8), Vector3(-16, 4.1, -8.1), Color(0.68, 0.12, 0.13))
	_box("Store awning", Vector3(6, 0.4, 1.5), Vector3(-33, 3.3, -5.4), Color(0.10, 0.42, 0.30))
	_box("Food corner awning", Vector3(9, 0.4, 1.4), Vector3(20, 5, -13.6), Color(0.89, 0.53, 0.12))
	for z in range(-70, 75, 18):
		_lamp(Vector3(8.5, 0, z))
		_lamp(Vector3(-9, 0, z + 4))
	for z in range(-45, 50, 25):
		_box("Power pole", Vector3(0.35, 8, 0.35), Vector3(-38, 4, z), Color(0.39, 0.40, 0.39))
	_box("Overhead cable", Vector3(0.08, 0.08, 105), Vector3(-38, 7.2, 0), Color(0.08, 0.09, 0.10))
	for p in [Vector3(-65,0,25), Vector3(-60,0,43), Vector3(-28,0,48), Vector3(3,0,47), Vector3(84,0,-38), Vector3(88,0,12), Vector3(80,0,45), Vector3(-70,0,-34)]:
		_tree(p)
	_box("Mall parking", Vector3(24, 0.1, 22), Vector3(34, 0.02, 34), Color(0.27, 0.29, 0.30))
	for x in range(25, 45, 5):
		_box("Parking bay", Vector3(0.12, 0.03, 7), Vector3(x, 0.1, 33), Color(0.87, 0.85, 0.73))
	_box("Petrol pump", Vector3(3, 0.25, 2), Vector3(75, 0.15, -25), Color(0.85, 0.85, 0.80))
	_box("Pump red top", Vector3(2.8, 1.3, 1.8), Vector3(75, 1, -25), Color(0.82, 0.12, 0.12))

func _building(label_text: String, pos: Vector3, size: Vector3, color: Color) -> void:
	_box(label_text, size, pos, color, true)
	_box(label_text + " roof", Vector3(size.x + 0.7, 0.35, size.z + 0.7), Vector3(pos.x, pos.y + size.y * 0.5 + 0.16, pos.z), Color(0.26, 0.30, 0.32))
	for xx in [-size.x * 0.28, 0.0, size.x * 0.28]:
		_box("Shop window", Vector3(maxf(0.8, size.x * 0.13), 1.35, 0.12), Vector3(pos.x + xx, pos.y - size.y * 0.08, pos.z - size.z * 0.5 - 0.08), Color(0.10, 0.24, 0.30))
	_box("Front door", Vector3(1.2, 2.2, 0.16), Vector3(pos.x, pos.y - size.y * 0.5 + 1.1, pos.z - size.z * 0.5 - 0.12), Color(0.28, 0.16, 0.09))

func _lamp(pos: Vector3) -> void:
	_box("Lamp post", Vector3(0.18, 5.2, 0.18), pos + Vector3(0, 2.6, 0), Color(0.16, 0.19, 0.20))
	_box("Lamp arm", Vector3(1, 0.13, 0.13), pos + Vector3(0.42, 5, 0), Color(0.16, 0.19, 0.20))
	_box("Lamp light", Vector3(0.55, 0.16, 0.45), pos + Vector3(0.82, 4.9, 0), Color(1, 0.78, 0.40))

func _tree(pos: Vector3) -> void:
	_box("Tree trunk", Vector3(0.65, 3.6, 0.65), pos + Vector3(0, 1.8, 0), Color(0.29, 0.18, 0.10))
	var crown := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 2.1
	mesh.height = 4.2
	crown.mesh = mesh
	crown.position = pos + Vector3(0, 4, 0)
	crown.material_override = _mat(Color(0.13, 0.35, 0.20))
	add_child(crown)

func _build_players() -> void:
	var starts := [Vector3(-3, 0, 7), Vector3(-6, 0, 9), Vector3(-7, 0, 5)]
	for i in range(3):
		var body := CharacterBody3D.new()
		body.name = NAMES[i]
		body.position = starts[i]
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.42
		capsule.height = 1.8
		var visual := MeshInstance3D.new()
		visual.mesh = capsule
		visual.position.y = 0.95
		visual.material_override = _mat(COLORS[i])
		body.add_child(visual)
		var head := MeshInstance3D.new()
		var head_mesh := SphereMesh.new()
		head_mesh.radius = 0.27
		head_mesh.height = 0.54
		head.mesh = head_mesh
		head.position.y = 2
		head.material_override = _mat(Color(0.62, 0.39, 0.25))
		body.add_child(head)
		var collider := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = 0.42
		shape.height = 1.8
		collider.shape = shape
		collider.position.y = 0.95
		body.add_child(collider)
		add_child(body)
		players.append(body)
		if i > 0:
			body.visible = false

func _build_vehicles() -> void:
	vehicles.append(_vehicle("Auto-rickshaw", Vector3(2, 0, 3), Color(0.12, 0.65, 0.34), true))
	vehicles.append(_vehicle("City hatchback", Vector3(8, 0, 3), Color(0.08, 0.48, 0.82), false))
	vehicles.append(_vehicle("Delivery scooter", Vector3(-9, 0, -3), Color(0.88, 0.18, 0.12), false))
	vehicles.append(_vehicle("Highway jeep", Vector3(60, 0, 30), Color(0.80, 0.65, 0.20), false))

func _vehicle(label_text: String, pos: Vector3, color: Color, is_auto: bool) -> Node3D:
	var root := Node3D.new()
	root.name = label_text
	root.position = pos
	add_child(root)
	_part(root, Vector3(2.1, 0.7, 3.6), Vector3(0, 0.65, 0), color)
	_part(root, Vector3(1.65, 0.85, 1.6), Vector3(0, 1.25, -0.2), Color(0.10, 0.24, 0.30))
	if is_auto:
		_part(root, Vector3(2.0, 0.12, 3.5), Vector3(0, 1.8, 0), Color(0.92, 0.77, 0.18))
	for side in [-1.0, 1.0]:
		for front in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.35
			wheel_mesh.bottom_radius = 0.35
			wheel_mesh.height = 0.2
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI / 2
			wheel.position = Vector3(side * 1.08, 0.35, front * 1.15)
			wheel.material_override = _mat(Color(0.08, 0.08, 0.09))
			root.add_child(wheel)
	return root

func _part(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _mat(color)
	parent.add_child(mesh)

func _build_npcs() -> void:
	var spots := [Vector3(-20,0,-3), Vector3(-27,0,-5), Vector3(12,0,-4), Vector3(26,0,8), Vector3(-49,0,-4), Vector3(49,0,-15), Vector3(-37,0,8), Vector3(14,0,22), Vector3(72,0,18), Vector3(-7,0,14)]
	for i in range(spots.size()):
		var npc := Node3D.new()
		npc.position = spots[i]
		var body := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.34
		capsule.height = 1.55
		body.mesh = capsule
		body.position.y = 0.8
		body.material_override = _mat([Color(0.85,0.54,0.31), Color(0.20,0.47,0.74), Color(0.78,0.31,0.36)][i % 3])
		npc.add_child(body)
		add_child(npc)
		npcs.append(npc)

func _build_marker() -> void:
	marker = Node3D.new()
	marker.position = PICKUP
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.8
	torus.outer_radius = 2.1
	ring.mesh = torus
	ring.rotation_degrees.x = 90
	ring.position.y = 0.25
	ring.material_override = _mat(Color(0.1, 0.9, 1), 0.3, 1.5)
	marker.add_child(ring)
	var beam := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.12
	cylinder.bottom_radius = 0.55
	cylinder.height = 6
	beam.mesh = cylinder
	beam.position.y = 3
	beam.material_override = _mat(Color(0.1, 0.8, 1, 0.28), 0.3, 0.6)
	marker.add_child(beam)
	add_child(marker)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "BHARAT: CITY OF THREE   •   TRIPURA"
	title.position = Vector2(24, 18)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.35, 0.94, 1))
	layer.add_child(title)
	mission_label = Label.new()
	mission_label.position = Vector2(24, 65)
	mission_label.size = Vector2(500, 34)
	mission_label.add_theme_font_size_override("font_size", 19)
	layer.add_child(mission_label)
	objective_label = Label.new()
	objective_label.position = Vector2(24, 104)
	objective_label.size = Vector2(520, 58)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(objective_label)
	status_label = Label.new()
	status_label.position = Vector2(970, 22)
	status_label.size = Vector2(285, 90)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_font_size_override("font_size", 15)
	layer.add_child(status_label)
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(930, 650)
	progress_bar.size = Vector2(320, 20)
	progress_bar.show_percentage = false
	layer.add_child(progress_bar)
	var controls := Label.new()
	controls.text = "WASD Move/Drive  •  SHIFT Sprint  •  E Interact/Vehicle  •  1-3 Switch  •  M Mission"
	controls.position = Vector2(24, 674)
	controls.size = Vector2(1000, 24)
	controls.add_theme_font_size_override("font_size", 13)
	layer.add_child(controls)
	toast_label = Label.new()
	toast_label.position = Vector2(250, 190)
	toast_label.size = Vector2(780, 46)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 23)
	toast_label.add_theme_color_override("font_color", Color(0.45, 0.96, 1))
	layer.add_child(toast_label)

func _physics_process(delta: float) -> void:
	if driving:
		_drive(delta)
	else:
		var body := players[active]
		var direction := Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0, Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")).normalized()
		var speed := 9.0 if Input.is_action_pressed("sprint") else 5.4
		body.velocity.x = direction.x * speed
		body.velocity.z = direction.z * speed
		if not body.is_on_floor():
			body.velocity.y -= 20.0 * delta
		else:
			body.velocity.y = -0.5
		if direction.length() > 0.1:
			body.rotation.y = atan2(direction.x, direction.z)
		body.move_and_slide()
	for i in range(npcs.size()):
		npcs[i].position.y = absf(sin(elapsed * 1.8 + i * 0.7)) * 0.04
	_check_mission()

func _process(delta: float) -> void:
	elapsed += delta
	if marker:
		marker.rotation.y += delta * 0.7
	if toast_time > 0:
		toast_time -= delta
		toast_label.visible = toast_time > 0
	_update_hud()
	_update_camera(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_1"):
		_switch_character(0)
	elif event.is_action_pressed("switch_2"):
		_switch_character(1)
	elif event.is_action_pressed("switch_3"):
		_switch_character(2)
	elif event.is_action_pressed("interact"):
		_interact()
	elif event.is_action_pressed("mission_info"):
		_toast("MISSION: COLLECT THE FOOD ORDER AT MAA'S KITCHEN, THEN DELIVER IT TO THE BLUE MARKER.")

func _drive(delta: float) -> void:
	if active_vehicle == null:
		return
	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steer := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	active_vehicle.rotation.y += steer * delta * 1.7 * (1.0 if throttle >= 0 else -1.0)
	active_vehicle.position.x += sin(active_vehicle.rotation.y) * throttle * 12.0 * delta
	active_vehicle.position.z += cos(active_vehicle.rotation.y) * throttle * 12.0 * delta
	active_vehicle.position.x = clampf(active_vehicle.position.x, -110, 110)
	active_vehicle.position.z = clampf(active_vehicle.position.z, -115, 115)
	players[active].global_position = active_vehicle.global_position + Vector3(0, -5, 0)

func _interact() -> void:
	if driving:
		driving = false
		players[active].visible = true
		players[active].global_position = active_vehicle.global_position + Vector3(2.2, 0, 0)
		_toast("YOU LEFT THE VEHICLE")
		return
	var pos := players[active].global_position
	var nearest: Node3D
	var nearest_dist := 4.5
	for vehicle in vehicles:
		var d := pos.distance_to(vehicle.global_position)
		if d < nearest_dist:
			nearest = vehicle
			nearest_dist = d
	if nearest:
		active_vehicle = nearest
		driving = true
		players[active].visible = false
		_toast("VEHICLE ENTERED — WASD TO DRIVE")
	elif mission_stage == 0 and pos.distance_to(PICKUP) < 5:
		mission_stage = 1
		marker.position = DELIVERY
		_toast("ORDER COLLECTED — DELIVER IT TO THE BLUE MARKER")
	elif mission_stage == 1 and pos.distance_to(DELIVERY) < 5:
		_complete_delivery()
	elif pos.distance_to(SAFEHOUSE) < 9:
		_toast("SAFE HOUSE: REST, SAVE AND PLAN YOUR NEXT JOB")
	elif pos.distance_to(STORE) < 10:
		_toast("TRIPURA GENERAL STORE — SHOPPING FEATURE COMING SOON")
	elif pos.distance_to(MALL) < 13:
		_toast("CITY MALL — STORES AND CLOTHING FEATURE COMING SOON")
	else:
		_toast("EXPLORE THE MARKET, POND GHAT, MALL OR HIGHWAY DHABA")

func _check_mission() -> void:
	var pos := _controlled_position()
	if mission_stage == 0 and pos.distance_to(PICKUP) < 5:
		toast_label.text = "PRESS E TO COLLECT FOOD ORDER"
	elif mission_stage == 1:
		toast_label.text = "DELIVER THE ORDER TO THE BLUE MARKER"
		if pos.distance_to(DELIVERY) < 4:
			_complete_delivery()

func _complete_delivery() -> void:
	mission_stage = 2
	cash += 550
	marker.position = Vector3(-42, 0, 33)
	_toast("DELIVERY COMPLETE  +₹550  •  MISSION PASSED")

func _switch_character(index: int) -> void:
	if driving:
		_toast("EXIT THE VEHICLE BEFORE SWITCHING CHARACTERS")
		return
	if index == active:
		return
	players[active].visible = false
	active = index
	players[active].visible = true
	_toast(NAMES[index] + " SELECTED")

func _controlled_position() -> Vector3:
	return active_vehicle.global_position if driving and active_vehicle != null else players[active].global_position

func _update_camera(delta: float) -> void:
	if camera == null:
		return
	var target := _controlled_position()
	target.y += 1.6 if not driving else 1.8
	var offset := Vector3(0, 5.2, -8.5) if not driving else active_vehicle.global_transform.basis * Vector3(0, 6, -11)
	camera.global_position = camera.global_position.lerp(target + offset, clampf(delta * 5, 0, 1))
	camera.look_at(target, Vector3.UP)

func _update_hud() -> void:
	status_label.text = (NAMES[active] if not driving else "AUTO / CAR DRIVER") + "\n₹%s  •  AGARTALA, TRIPURA\nTIME %02d:%02d" % [str(cash), 17 + int(elapsed / 60) % 5, int(elapsed) % 60]
	if mission_stage == 0:
		mission_label.text = "STORY 01 — FIRST DELIVERY"
		objective_label.text = "Collect a food order at Maa's Kitchen, then deliver it to the blue marker."
		progress_bar.value = 0
	elif mission_stage == 1:
		mission_label.text = "STORY 01 — DELIVERY RUN"
		objective_label.text = "Take the order to the customer near the highway junction."
		progress_bar.value = 60
	else:
		mission_label.text = "STORY 01 — MISSION PASSED"
		objective_label.text = "Crew assembled. Explore the pond ghat, mall, safe house and highway dhaba."
		progress_bar.value = 100

func _toast(message: String) -> void:
	toast_label.text = message if toast_label != null else ""
	if toast_label != null:
		toast_label.visible = true
	toast_time = 3.2

func _box(label_text: String, size: Vector3, pos: Vector3, color: Color, solid: bool = false) -> Node3D:
	var root: Node3D = StaticBody3D.new() if solid else Node3D.new()
	root.name = label_text
	root.position = pos
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = _mat(color)
	root.add_child(mesh)
	if solid:
		var collider := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		collider.shape = box_shape
		root.add_child(collider)
	add_child(root)
	return root

func _mat(color: Color, roughness: float = 0.82, emission: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	if emission > 0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	return material
