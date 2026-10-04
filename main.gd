extends Node3D

# --- Node References & Configuration ---
@export var player_scene: PackedScene
@export var camera_distance: float = 8.0
@export var camera_height: float = 5.0

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light: DirectionalLight3D = $DirectionalLight3D
@onready var ui_canvas: CanvasLayer = $UICanvas
@onready var joystick_touch_zone: Control = $UICanvas/JoystickTouchZone

# --- Game State Variables ---
var player: CharacterBody3D = null
var main_camera: Camera3D = null
var pandal_nodes: Array[Node3D] = []
var vehicle_nodes: Array[Node3D] = []

# Touch Controls State
var touch_pad_center: Vector2 = Vector2.ZERO
var touch_pad_current: Vector2 = Vector2.ZERO
var is_touching_joystick: bool = false
var joystick_pointer_id: int = -1

func _ready() -> void:
	setup_lighting_and_environment()
	spawn_player()
	setup_camera()
	build_agartala_city()
	setup_android_ui()

func _process(delta: float) -> void:
	update_camera_position()
	process_touch_input()
	update_vehicles(delta)

# --- GDScript Type Fixes for Godot 4.3 Static Checks ---

func build_agartala_city() -> void:
	# Line 31 fix: Explicitly typing "m" as MeshInstance3D instead of using "var m :="
	var m: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = Vector3(10.0, 1.0, 10.0)
	m.mesh = box_mesh
	
	var static_body: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = box_mesh.size
	col_shape.shape = box_shape
	
	static_body.add_child(col_shape)
	m.add_child(static_body)
	add_child(m)
	
	spawn_pandal_structures()

func spawn_pandal_structures() -> void:
	var pandal_positions: Array[Vector3] = [
		Vector3(15.0, 0.0, 15.0),
		Vector3(-20.0, 0.0, 10.0),
		Vector3(0.0, 0.0, -25.0)
	]
	
	# Explicit type loop variable to avoid Variant inference
	for pos: Vector3 in pandal_positions:
		var pandal_base: Node3D = Node3D.new()
		pandal_base.position = pos
		
		var pandal_mesh: MeshInstance3D = MeshInstance3D.new()
		var prism: PrismMesh = PrismMesh.new()
		prism.size = Vector3(6.0, 8.0, 6.0)
		pandal_mesh.mesh = prism
		pandal_mesh.position.y = 4.0
		
		pandal_base.add_child(pandal_mesh)
		add_child(pandal_base)
		pandal_nodes.append(pandal_base)

func _unhandled_input(event: InputEvent) -> void:
	# Line 139 & Line 142 fixes: Casting event explicitly to touch types
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		handle_screen_touch(touch_event)
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		handle_screen_drag(drag_event)

func handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if joystick_pointer_id == -1 and event.position.x < (get_viewport().get_visible_rect().size.x / 2.0):
			joystick_pointer_id = event.index
			touch_pad_center = event.position
			touch_pad_current = event.position
			is_touching_joystick = true
	else:
		if event.index == joystick_pointer_id:
			joystick_pointer_id = -1
			is_touching_joystick = false
			touch_pad_current = touch_pad_center

func handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_pointer_id:
		touch_pad_current = event.position

func process_touch_input() -> void:
	if not is_touching_joystick or player == null:
		return
	
	var drag_vector: Vector2 = touch_pad_current - touch_pad_center
	var max_len: float = 100.0
	
	# Line 144 fix: Explicit float typing for x offset/axis
	var x: float = clamp(drag_vector.x / max_len, -1.0, 1.0)
	var y: float = clamp(drag_vector.y / max_len, -1.0, 1.0)
	
	var move_dir: Vector3 = Vector3(x, 0.0, y).normalized()
	
	if player.has_method("set_touch_movement"):
		player.call("set_touch_movement", move_dir)

# --- Helper Setup Functions ---

func setup_lighting_and_environment() -> void:
	if directional_light == null:
		directional_light = DirectionalLight3D.new()
		directional_light.name = "DirectionalLight3D"
		add_child(directional_light)
	
	directional_light.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	directional_light.shadow_enabled = true

func spawn_player() -> void:
	if player_scene != null:
		player = player_scene.instantiate() as CharacterBody3D
	else:
		player = CharacterBody3D.new()
		var col: CollisionShape3D = CollisionShape3D.new()
		var caps: CapsuleShape3D = CapsuleShape3D.new()
		col.shape = caps
		player.add_child(col)
		
		var body_mesh: MeshInstance3D = MeshInstance3D.new()
		var caps_mesh: CapsuleMesh = CapsuleMesh.new()
		body_mesh.mesh = caps_mesh
		player.add_child(body_mesh)
	
	player.position = Vector3(0.0, 1.0, 0.0)
	add_child(player)

func setup_camera() -> void:
	main_camera = Camera3D.new()
	main_camera.name = "MainCamera"
	add_child(main_camera)
	main_camera.make_current()

func update_camera_position() -> void:
	if player != null and main_camera != null:
		var target_pos: Vector3 = player.position + Vector3(0.0, camera_height, camera_distance)
		main_camera.position = main_camera.position.lerp(target_pos, 0.1)
		main_camera.look_at(player.position, Vector3.UP)

func setup_android_ui() -> void:
	if ui_canvas == null:
		ui_canvas = CanvasLayer.new()
		add_child(ui_canvas)

func update_vehicles(delta: float) -> void:
	for vehicle: Node3D in vehicle_nodes:
		vehicle.rotate_y(0.5 * delta)
