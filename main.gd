extends Node3D

# PANDAL HOPPING: AN AGARTALA STORY
# Cinematic foundation: realistic lighting, camera language, weather,
# Android-friendly third-person movement and asset-ready world.

var player: CharacterBody3D
var camera: Camera3D
var speed := 5.5
var sprint_speed := 8.0
var gravity := 18.0
var yaw := 0.0
var pitch := -12.0
var joystick_touch := -1
var look_touch := -1
var move_input := Vector2.ZERO
var look_input := Vector2.ZERO
var rain := false

func _ready():
	create_cinematic_world()
	create_player()
	create_ui()

func create_cinematic_world():
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var mat := ProceduralSkyMaterial.new()
	mat.sky_top_color = Color("#071226")
	mat.sky_horizon_color = Color("#6d8191")
	mat.ground_bottom_color = Color("#07100d")
	mat.ground_horizon_color = Color("#53615d")
	mat.sun_angle_max = 12.0
	mat.sun_curve = 0.08
	sky.sky_material = mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_bloom = 0.12
	env.fog_enabled = true
	env.fog_light_color = Color("#87979b")
	env.fog_light_energy = 0.35
	env.fog_density = 0.006
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "CinematicSun"
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_color = Color("#fff1d0")
	sun.light_energy = 1.7
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	add_child(sun)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 8, 8)
	fill.light_color = Color("#87a9ff")
	fill.light_energy = 2.0
	fill.omni_range = 35.0
	add_child(fill)

	create_box("Ground", Vector3(140, 0.25, 140), Vector3(0,-0.125,0), Color("#303936"), 0.0)
	create_box("MainRoad", Vector3(14,0.12,140), Vector3(0,0.06,0), Color("#15181a"), 0.05)
	create_box("CrossRoad", Vector3(140,0.12,14), Vector3(0,0.07,0), Color("#15181a"), 0.05)

	for z in range(-60,61,8):
		create_box("LaneMark", Vector3(0.25,0.03,4.0), Vector3(0,0.15,z), Color("#d7d4bc"))
	for x in range(-60,61,8):
		create_box("LaneMark", Vector3(4.0,0.03,0.25), Vector3(x,0.16,0), Color("#d7d4bc"))

	create_building("Badharghat Home", Vector3(14,7,12), Vector3(-25,3.5,-24), Color("#a77d5d"))
	create_building("ANI Mall", Vector3(20,13,16), Vector3(27,6.5,-22), Color("#64758a"))
	create_building("Restaurant", Vector3(12,5,10), Vector3(-25,2.5,23), Color("#7b5543"))
	create_building("Tea Stall", Vector3(7,3.5,7), Vector3(24,1.75,23), Color("#8b6a42"))
	create_building("Railway Station", Vector3(22,8,12), Vector3(30,4,38), Color("#77736b"))
	create_building("Airport", Vector3(28,7,18), Vector3(-32,3.5,40), Color("#64737b"))

	for p in [Vector3(-10,0,18),Vector3(12,0,-18),Vector3(-40,0,-5),Vector3(40,0,5),Vector3(-8,0,-40),Vector3(10,0,40)]:
		create_tree(p)

	create_street_lights()

func create_box(n:String, size:Vector3, pos:Vector3, color:Color, metallic:=0.0):
	var body := StaticBody3D.new()
	body.name = n
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.72
	box.material = material
	mesh.mesh = box
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var cs := BoxShape3D.new()
	cs.size = size
	shape.shape = cs
	body.add_child(shape)
	body.position = pos
	add_child(body)

func create_building(n:String, size:Vector3, pos:Vector3, color:Color):
	create_box(n,size,pos,color,0.0)
	# Window bands make the prototype read as a real city block instead of plain cubes.
	for y in range(2, int(size.y), 2):
		var band := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(size.x*0.72,0.65,0.08)
		var glass := StandardMaterial3D.new()
		glass.albedo_color = Color("#182b3a")
		glass.metallic = 0.25
		glass.roughness = 0.18
		glass.emission_enabled = true
		glass.emission = Color("#203c52")
		glass.emission_energy_multiplier = 0.35
		bm.material = glass
		band.mesh = bm
		band.position = pos + Vector3(0,y,-size.z*0.51)
		add_child(band)

func create_tree(pos:Vector3):
	var trunk := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 0.22
	tm.bottom_radius = 0.34
	tm.height = 3.0
	tm.material = StandardMaterial3D.new()
	tm.material.albedo_color = Color("#3f2c1f")
	trunk.mesh = tm
	trunk.position = pos + Vector3(0,1.5,0)
	add_child(trunk)
	for i in range(4):
		var crown := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 1.7
		sm.height = 3.2
		sm.material = StandardMaterial3D.new()
		sm.material.albedo_color = Color("#23482f")
		crown.mesh = sm
		crown.scale = Vector3(1.1,0.75,1.1)
		crown.position = pos + Vector3((i%2)*1.2-0.6,3.2+(i%2)*0.6,(i/2)*1.1-0.55)
		add_child(crown)

func create_street_lights():
	for x in [-7.0,7.0]:
		for z in range(-55,56,18):
			var pole := MeshInstance3D.new()
			var pm := CylinderMesh.new()
			pm.top_radius = 0.08
			pm.bottom_radius = 0.12
			pm.height = 5.5
			pm.material = StandardMaterial3D.new()
			pm.material.albedo_color = Color("#24272b")
			pole.mesh = pm
			pole.position = Vector3(x,2.75,z)
			add_child(pole)
			var light := OmniLight3D.new()
			light.position = Vector3(x,5.4,z)
			light.light_color = Color("#ffdca0")
			light.light_energy = 4.0
			light.omni_range = 9.0
			add_child(light)

func create_player():
	player = CharacterBody3D.new()
	player.name = "Player"
	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.height = 1.9
	capsule.radius = 0.38
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color("#a86f4f")
	skin.roughness = 0.58
	capsule.material = skin
	mesh.mesh = capsule
	mesh.position.y = 1.05
	player.add_child(mesh)
	var shape := CollisionShape3D.new()
	var cs := CapsuleShape3D.new()
	cs.height = 1.9
	cs.radius = 0.38
	shape.shape = cs
	shape.position.y = 1.0
	player.add_child(shape)
	player.position = Vector3(0,0.15,8)
	add_child(player)

	camera = Camera3D.new()
	camera.current = true
	camera.fov = 70.0
	camera.position = Vector3(0,4.0,7.5)
	player.add_child(camera)

func _physics_process(delta):
	if not player:
		return
	var input := move_input
	if input.length() < 0.05:
		input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var dir := Vector3(input.x,0,input.y)
	dir = dir.rotated(Vector3.UP, yaw).normalized()
	var current_speed := sprint_speed if Input.is_action_pressed("ui_accept") else speed
	player.velocity.x = dir.x * current_speed
	player.velocity.z = dir.z * current_speed
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	else:
		player.velocity.y = 0
	if dir.length() > 0.05:
		player.rotation.y = lerp_angle(player.rotation.y, atan2(-dir.x,-dir.z), delta*8.0)
	player.move_and_slide()
	yaw += look_input.x * delta * 2.4
	pitch = clamp(pitch + look_input.y * delta * 1.8, -35.0, 20.0)
	camera.rotation_degrees = Vector3(pitch,0,0)
	camera.position = Vector3(0,3.5,7.5)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().size.x * 0.45:
				joystick_touch = event.index
			else:
				look_touch = event.index
		elif event.index == joystick_touch:
			joystick_touch = -1
			move_input = Vector2.ZERO
		elif event.index == look_touch:
			look_touch = -1
			look_input = Vector2.ZERO
	elif event is InputEventScreenDrag:
		var center := Vector2(120, get_viewport().size.y-120)
		if event.index == joystick_touch:
			move_input = (event.position-center)/90.0
			move_input = move_input.limit_length(1.0)
		elif event.index == look_touch:
			look_input = event.relative/70.0
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		look_input = event.relative/70.0

func create_ui():
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "PANDAL HOPPING\nAN AGARTALA STORY"
	title.position = Vector2(28,24)
	title.add_theme_font_size_override("font_size",24)
	title.modulate = Color("#f4f1e8")
	layer.add_child(title)

	var hint := Label.new()
	hint.text = "Badharghat  •  Agartala\nTouch left to move  •  Touch right to look"
	hint.position = Vector2(28,88)
	hint.add_theme_font_size_override("font_size",14)
	hint.modulate = Color("#b8c2c7")
	layer.add_child(hint)

	var brand := Label.new()
	brand.text = "A GAME BY ANI STUDIO"
	brand.position = Vector2(28,150)
	brand.add_theme_font_size_override("font_size",12)
	brand.modulate = Color("#9aa8ff")
	layer.add_child(brand)
