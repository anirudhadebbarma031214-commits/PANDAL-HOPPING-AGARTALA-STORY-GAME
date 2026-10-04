extends Node3D

# PANDAL HOPPING: AN AGARTALA STORY
# Stable mobile foundation. World generation is staged to avoid startup black screens.

var player: CharacterBody3D
var camera_pivot: Node3D
var camera: Camera3D
var speed: float = 5.5
var sprint_speed: float = 8.0
var gravity: float = 18.0
var yaw: float = 0.0
var pitch: float = -12.0
var joystick_touch: int = -1
var look_touch: int = -1
var move_input: Vector2 = Vector2.ZERO
var look_input: Vector2 = Vector2.ZERO

var loading_layer: CanvasLayer
var loading_root: ColorRect
var loading_bar: ColorRect
var loading_status: Label

func _ready() -> void:
    create_loading_screen()
    await get_tree().process_frame
    set_loading_progress(0.10, "Starting Agartala...")
    create_environment()
    await get_tree().process_frame
    set_loading_progress(0.28, "Creating roads...")
    create_basic_city()
    await get_tree().process_frame
    set_loading_progress(0.48, "Adding landmarks...")
    create_landmarks()
    await get_tree().process_frame
    set_loading_progress(0.65, "Preparing player...")
    create_player()
    await get_tree().process_frame
    set_loading_progress(0.80, "Adding city life...")
    create_city_life()
    create_ui()
    await get_tree().process_frame
    set_loading_progress(1.0, "Welcome to Agartala")
    await get_tree().create_timer(0.35).timeout
    if is_instance_valid(loading_layer):
        loading_layer.queue_free()

func create_loading_screen() -> void:
    loading_layer = CanvasLayer.new()
    loading_layer.layer = 100
    add_child(loading_layer)

    loading_root = ColorRect.new()
    loading_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    loading_root.color = Color("#02050a")
    loading_layer.add_child(loading_root)

    var brand := Label.new()
    brand.text = "A GAME BY ANI STUDIO"
    brand.position = Vector2(42, 42)
    brand.add_theme_font_size_override("font_size", 16)
    brand.modulate = Color("#aebcff")
    loading_root.add_child(brand)

    var title := Label.new()
    title.text = "PANDAL HOPPING"
    title.position = Vector2(42, 150)
    title.add_theme_font_size_override("font_size", 42)
    title.modulate = Color("#f4f2eb")
    loading_root.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "AN AGARTALA STORY"
    subtitle.position = Vector2(45, 204)
    subtitle.add_theme_font_size_override("font_size", 22)
    subtitle.modulate = Color("#d5dbe4")
    loading_root.add_child(subtitle)

    var location := Label.new()
    location.text = "AGARTALA • TRIPURA"
    location.position = Vector2(45, 246)
    location.add_theme_font_size_override("font_size", 13)
    location.modulate = Color("#8795a5")
    loading_root.add_child(location)

    var tip := Label.new()
    tip.text = "THE CITY REMEMBERS YOU."
    tip.position = Vector2(45, 315)
    tip.add_theme_font_size_override("font_size", 18)
    tip.modulate = Color("#e5e7eb")
    loading_root.add_child(tip)

    loading_status = Label.new()
    loading_status.text = "Starting..."
    loading_status.position = Vector2(45, 0)
    loading_status.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    loading_status.position = Vector2(45, -145)
    loading_status.add_theme_font_size_override("font_size", 15)
    loading_status.modulate = Color("#aeb7c3")
    loading_root.add_child(loading_status)

    var track := ColorRect.new()
    track.position = Vector2(45, 0)
    track.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    track.position = Vector2(45, -105)
    track.size = Vector2(520, 8)
    track.color = Color("#252c36")
    loading_root.add_child(track)

    loading_bar = ColorRect.new()
    loading_bar.position = Vector2(45, 0)
    loading_bar.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    loading_bar.position = Vector2(45, -105)
    loading_bar.size = Vector2(0, 8)
    loading_bar.color = Color("#aebcff")
    loading_root.add_child(loading_bar)

func set_loading_progress(value: float, status: String) -> void:
    if not is_instance_valid(loading_bar):
        return
    var v := clamp(value, 0.0, 1.0)
    loading_bar.size.x = 520.0 * v
    if is_instance_valid(loading_status):
        loading_status.text = status + "  " + str(int(v * 100.0)) + "%"

func mat(color: Color, roughness: float = 0.7, metallic: float = 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    m.metallic = metallic
    return m

func glow_mat(color: Color, energy: float = 1.5) -> StandardMaterial3D:
    var m := mat(color, 0.3, 0.05)
    m.emission_enabled = true
    m.emission = color
    m.emission_energy_multiplier = energy
    return m

func box_mesh(size: Vector3, pos: Vector3, material: Material, parent: Node3D = self) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = material
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    parent.add_child(node)
    return node

func cylinder_mesh(radius: float, height: float, pos: Vector3, material: Material, parent: Node3D = self) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.92
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.material = material
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    parent.add_child(node)
    return node

func create_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#172235")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#b8c7dd")
    env.ambient_light_energy = 0.72
    env.tonemap_mode = Environment.TONE_MAPPER_ACES
    env.fog_enabled = true
    env.fog_light_color = Color("#9ba7a3")
    env.fog_light_energy = 0.18
    env.fog_density = 0.002
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52, -28, 0)
    sun.light_color = Color("#fff0d0")
    sun.light_energy = 1.45
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 55.0
    add_child(sun)

func create_basic_city() -> void:
    var ground := mat(Color("#3e5141"), 0.98)
    # Solid floor collision: without this the player falls through the visual ground,
    # the camera follows them below the map, and Android can appear to show a black screen.
    create_floor_collision()
    var road := mat(Color("#25282b"), 0.92)
    var sidewalk := mat(Color("#77736b"), 0.86)
    var marking := mat(Color("#e8dfbd"), 0.6)

    box_mesh(Vector3(180, 0.4, 180), Vector3(0, -0.2, 0), ground)
    box_mesh(Vector3(18, 0.12, 180), Vector3(0, 0.05, 0), road)
    box_mesh(Vector3(180, 0.12, 18), Vector3(0, 0.06, 0), road)
    box_mesh(Vector3(6, 0.16, 180), Vector3(-12, 0.14, 0), sidewalk)
    box_mesh(Vector3(6, 0.16, 180), Vector3(12, 0.14, 0), sidewalk)
    box_mesh(Vector3(180, 0.16, 6), Vector3(0, 0.15, -12), sidewalk)
    box_mesh(Vector3(180, 0.16, 6), Vector3(0, 0.15, 12), sidewalk)

    for z in range(-80, 81, 12):
        box_mesh(Vector3(0.14, 0.025, 5.5), Vector3(0, 0.13, z), marking)
    for x in range(-80, 81, 12):
        box_mesh(Vector3(5.5, 0.025, 0.14), Vector3(x, 0.14, 0), marking)

    create_building("BADHARGHAT HOME", Vector3(-30, 0, -28), Vector3(15, 8, 12), Color("#b97f5a"))
    create_building("ANI MALL", Vector3(32, 0, -28), Vector3(24, 13, 18), Color("#66798c"))
    create_building("RESTAURANT", Vector3(-30, 0, 28), Vector3(15, 6, 12), Color("#8d6047"))
    create_building("TEA STALL", Vector3(30, 0, 28), Vector3(8, 4, 7), Color("#a77a4c"))
    create_building("RAILWAY STATION", Vector3(45, 0, 52), Vector3(27, 9, 15), Color("#817d72"))
    create_building("MBB AIRPORT", Vector3(-48, 0, 50), Vector3(34, 9, 22), Color("#70818a"))

    for i in range(6):
        var x := -58.0 + float(i % 3) * 9.0
        var z := 5.0 + float(i / 3) * 10.0
        create_building("SHOP_%02d" % i, Vector3(x, 0, z), Vector3(7, 4.5, 6.5), Color("#806b57"))

    for p in [Vector3(-8,0,20), Vector3(16,0,-19), Vector3(-48,0,-5), Vector3(48,0,5), Vector3(-8,0,-48), Vector3(10,0,48)]:
        create_tree(p)

func create_floor_collision() -> void:
    var floor_body := StaticBody3D.new()
    floor_body.name = "WorldFloorCollision"
    add_child(floor_body)

    var shape_node := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(180.0, 0.4, 180.0)
    shape_node.shape = shape
    shape_node.position = Vector3(0, -0.2, 0)
    floor_body.add_child(shape_node)

func create_building(n: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var root := Node3D.new()
    root.name = n
    root.position = pos
    add_child(root)
    box_mesh(size, Vector3(0, size.y * 0.5, 0), mat(color, 0.76), root)
    box_mesh(Vector3(size.x + 0.4, 0.3, size.z + 0.4), Vector3(0, size.y + 0.15, 0), mat(color.darkened(0.18), 0.8), root)

    var floors := max(1, int(size.y / 2.8))
    var windows := max(2, int(size.x / 3.5))
    for f in range(floors):
        for w in range(windows):
            var x := -size.x * 0.5 + 1.5 + float(w) * ((size.x - 3.0) / max(1, windows - 1))
            var y := 1.25 + float(f) * 2.45
            box_mesh(Vector3(1.25, 1.05, 0.08), Vector3(x, y, -size.z * 0.505), mat(Color("#173044"), 0.2, 0.15), root)

func create_tree(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    cylinder_mesh(0.3, 4.0, Vector3(0, 2.0, 0), mat(Color("#4b3425"), 0.92), root)
    for i in range(4):
        var sphere := SphereMesh.new()
        sphere.radius = 1.35
        sphere.height = 2.5
        sphere.material = mat(Color("#23522f"), 0.96)
        var crown := MeshInstance3D.new()
        crown.mesh = sphere
        crown.position = Vector3(float(i % 2) * 1.5 - 0.75, 4.0 + float(i / 2) * 0.75, float(i) * 0.35 - 0.5)
        root.add_child(crown)

func create_landmarks() -> void:
    create_landmark("UJJAYANTA PALACE", Vector3(-72,0,-55), Vector3(28,12,20), Color("#e8e4d6"))
    create_landmark("HERITAGE PARK", Vector3(-92,0,-20), Vector3(22,5,17), Color("#486b4e"))
    create_landmark("TRIPURA STATE MUSEUM", Vector3(-68,0,-82), Vector3(19,8,14), Color("#d6d0bf"))
    create_landmark("JAGANNATH TEMPLE", Vector3(-40,0,-65), Vector3(13,10,13), Color("#c7a36a"))
    create_landmark("TRIPURA POLICE HQ", Vector3(70,0,-55), Vector3(22,8,14), Color("#68717b"))
    create_landmark("CITY CENTRE MALL", Vector3(75,0,-20), Vector3(28,12,20), Color("#657b91"))
    create_landmark("BADHARGHAT", Vector3(0,0,75), Vector3(32,7,24), Color("#9a775d"))

func create_landmark(n: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var root := Node3D.new()
    root.name = n
    root.position = pos
    add_child(root)
    box_mesh(size, Vector3(0,size.y*0.5,0), mat(color,0.72), root)
    box_mesh(Vector3(size.x*0.75,0.5,0.18), Vector3(0,size.y*0.62,-size.z*0.52), glow_mat(Color("#304d78"),0.65), root)

    if "PALACE" in n:
        for x in [-8.0, 0.0, 8.0]:
            cylinder_mesh(1.8, 6.0, Vector3(x,size.y+3.0,0), mat(color.lightened(0.1),0.72), root)
    elif "TEMPLE" in n:
        cylinder_mesh(2.8, 7.0, Vector3(0,size.y+3.5,0), mat(color.lightened(0.1),0.72), root)

func create_city_life() -> void:
    create_traffic()
    create_pedestrians()
    create_street_lights()

func create_traffic() -> void:
    for i in range(5):
        var p := Vector3(-4.0 if i % 2 == 0 else 4.0, 0.55, -40.0 + float(i) * 18.0)
        create_car(p, i == 0)

func create_car(pos: Vector3, dark: bool = false) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    var body_color := Color("#20252a") if dark else Color("#b53f36")
    box_mesh(Vector3(3.3,0.75,1.55), Vector3(0,0.62,0), mat(body_color,0.38,0.4), root)
    box_mesh(Vector3(2.1,0.65,1.35), Vector3(0,1.15,0), mat(Color("#172934"),0.15,0.25), root)
    for x in [-1.2,1.2]:
        for z in [-0.6,0.6]:
            var wheel := CylinderMesh.new()
            wheel.top_radius = 0.36
            wheel.bottom_radius = 0.36
            wheel.height = 0.2
            wheel.material = mat(Color("#0b0c0d"),0.96)
            var wn := MeshInstance3D.new()
            wn.mesh = wheel
            wn.rotation_degrees = Vector3(90,0,0)
            wn.position = Vector3(x,0.36,z)
            root.add_child(wn)
    box_mesh(Vector3(0.55,0.22,0.08), Vector3(0,0.72,-0.81), glow_mat(Color("#ffe0a0"),1.2), root)

func create_street_lights() -> void:
    for x in [-8.8, 8.8]:
        for z in range(-70,71,35):
            cylinder_mesh(0.08,5.5,Vector3(x,2.75,z),mat(Color("#25292c"),0.4,0.6))
            box_mesh(Vector3(1.0,0.14,0.14),Vector3(x + (-0.9 if x < 0 else 0.9),5.3,z),mat(Color("#25292c"),0.4,0.6))

func create_pedestrians() -> void:
    for i in range(8):
        var p := Vector3(-65.0 + float((i * 17) % 130), 0, -65.0 + float((i * 29) % 130))
        var person := Node3D.new()
        person.name = "NPC_%02d" % i
        person.position = p
        add_child(person)
        cylinder_mesh(0.22,1.05,Vector3(0,0.95,0),mat(Color("#34465a"),0.8),person)
        var head := SphereMesh.new()
        head.radius = 0.15
        head.height = 0.3
        head.material = mat(Color("#a87456"),0.76)
        var hn := MeshInstance3D.new()
        hn.mesh = head
        hn.position = Vector3(0,1.75,0)
        person.add_child(hn)

func create_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0,0.05,8)
    add_child(player)

    var body := Node3D.new()
    player.add_child(body)
    cylinder_mesh(0.38,1.05,Vector3(0,1.05,0),mat(Color("#26384d"),0.62),body)
    var head := SphereMesh.new()
    head.radius = 0.24
    head.height = 0.48
    head.material = mat(Color("#a86f4f"),0.72)
    var hn := MeshInstance3D.new()
    hn.mesh = head
    hn.position = Vector3(0,1.95,0)
    body.add_child(hn)

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.height = 2.0
    capsule.radius = 0.38
    collision.shape = capsule
    collision.position.y = 1.0
    player.add_child(collision)

    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0,2.7,0)
    player.add_child(camera_pivot)

    camera = Camera3D.new()
    camera.current = true
    camera.fov = 68.0
    camera.near = 0.05
    camera.far = 350.0
    camera.position = Vector3(0,1.0,7.2)
    camera_pivot.add_child(camera)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        return

    var input_vector := move_input
    if input_vector.length() < 0.05:
        input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

    var dir := Vector3(input_vector.x,0,input_vector.y)
    dir = dir.rotated(Vector3.UP,yaw)
    if dir.length() > 1.0:
        dir = dir.normalized()

    var current_speed := sprint_speed if Input.is_action_pressed("ui_accept") else speed
    player.velocity.x = dir.x * current_speed
    player.velocity.z = dir.z * current_speed

    if not player.is_on_floor():
        player.velocity.y -= gravity * delta
    else:
        player.velocity.y = 0.0

    if dir.length() > 0.05:
        player.rotation.y = lerp_angle(player.rotation.y, atan2(-dir.x,-dir.z), delta*8.0)

    player.move_and_slide()

    yaw += look_input.x * delta * 2.4
    pitch = clamp(pitch + look_input.y * delta * 1.8,-35.0,20.0)
    camera_pivot.rotation.y = yaw
    camera_pivot.rotation_degrees.x = pitch

func _input(event: InputEvent) -> void:
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
        var center := Vector2(120,get_viewport().size.y-120)
        if event.index == joystick_touch:
            move_input = ((event.position-center)/90.0).limit_length(1.0)
        elif event.index == look_touch:
            look_input = event.relative/70.0
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        look_input = event.relative/70.0

func create_ui() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 10
    add_child(layer)

    var title := Label.new()
    title.text = "PANDAL HOPPING\nAN AGARTALA STORY"
    title.position = Vector2(28,24)
    title.add_theme_font_size_override("font_size",24)
    title.modulate = Color("#f4f1e8")
    layer.add_child(title)

    var mission := Label.new()
    mission.text = "CURRENT MISSION\nTHE CALL FROM HOME"
    mission.position = Vector2(28,100)
    mission.add_theme_font_size_override("font_size",15)
    mission.modulate = Color("#d5dbea")
    layer.add_child(mission)

    var controls := Label.new()
    controls.text = "LEFT: MOVE   •   RIGHT: LOOK\nWASD / ARROWS: MOVE   •   SHIFT/SPACE: SPRINT"
    controls.position = Vector2(28,0)
    controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    controls.position = Vector2(28,-58)
    controls.add_theme_font_size_override("font_size",13)
    controls.modulate = Color("#b8c1cc")
    layer.add_child(controls)

    var phone := Button.new()
    phone.text = "PHONE"
    phone.position = Vector2(0,28)
    phone.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    phone.position = Vector2(-140,28)
    phone.size = Vector2(112,48)
    layer.add_child(phone)

    var phone_panel := ColorRect.new()
    phone_panel.color = Color("#0b1018")
    phone_panel.position = Vector2(0,0)
    phone_panel.set_anchors_preset(Control.PRESET_CENTER)
    phone_panel.position = Vector2(-180,-230)
    phone_panel.size = Vector2(360,460)
    phone_panel.visible = false
    layer.add_child(phone_panel)

    var phone_text := Label.new()
    phone_text.text = "ANI PHONE\n\nCALLS   MESSAGES   MAP\n\nANI PAY   CAMERA\n\nTraffic & legal notices"
    phone_text.position = Vector2(24,28)
    phone_text.add_theme_font_size_override("font_size",19)
    phone_text.modulate = Color("#e8edf4")
    phone_panel.add_child(phone_text)
    phone.pressed.connect(func(): phone_panel.visible = not phone_panel.visible)
