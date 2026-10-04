extends Node3D

# PANDAL HOPPING: AN AGARTALA STORY
# 3D prototype foundation - detailed procedural environment.

var player: CharacterBody3D
var camera: Camera3D
var speed: float = 5.5
var sprint_speed: float = 8.0
var gravity: float = 18.0
var yaw: float = 0.0
var pitch: float = -10.0
var joystick_touch: int = -1
var look_touch: int = -1
var move_input: Vector2 = Vector2.ZERO
var look_input: Vector2 = Vector2.ZERO

func _ready() -> void:
    create_world()
    create_player()
    create_ui()

func mat(color: Color, roughness: float = 0.65, metallic: float = 0.0) -> StandardMaterial3D:
    var m: StandardMaterial3D = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    m.metallic = metallic
    return m

func emissive(color: Color, energy: float = 2.0) -> StandardMaterial3D:
    var m: StandardMaterial3D = mat(color, 0.25, 0.1)
    m.emission_enabled = true
    m.emission = color
    m.emission_energy_multiplier = energy
    return m

func mesh_box(size: Vector3, position: Vector3, material: Material, parent: Node3D = self) -> MeshInstance3D:
    var mi: MeshInstance3D = MeshInstance3D.new()
    var bm: BoxMesh = BoxMesh.new()
    bm.size = size
    bm.material = material
    mi.mesh = bm
    mi.position = position
    parent.add_child(mi)
    return mi

func mesh_cylinder(radius: float, height: float, position: Vector3, material: Material, parent: Node3D = self) -> MeshInstance3D:
    var mi: MeshInstance3D = MeshInstance3D.new()
    var cm: CylinderMesh = CylinderMesh.new()
    cm.top_radius = radius * 0.92
    cm.bottom_radius = radius
    cm.height = height
    cm.material = material
    mi.mesh = cm
    mi.position = position
    parent.add_child(mi)
    return mi

func create_world() -> void:
    var we: WorldEnvironment = WorldEnvironment.new()
    var env: Environment = Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky: Sky = Sky.new()
    var sky_mat: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color("#08152b")
    sky_mat.sky_horizon_color = Color("#b7a88f")
    sky_mat.ground_bottom_color = Color("#111613")
    sky_mat.ground_horizon_color = Color("#65706c")
    sky_mat.sun_angle_max = 18.0
    sky_mat.sun_curve = 0.08
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_energy = 0.8
    env.tonemap_mode = Environment.TONE_MAPPER_ACES
    env.glow_enabled = true
    env.glow_intensity = 0.7
    env.glow_bloom = 0.08
    env.fog_enabled = true
    env.fog_light_color = Color("#9ba7a3")
    env.fog_light_energy = 0.22
    env.fog_density = 0.003
    we.environment = env
    add_child(we)

    var sun: DirectionalLight3D = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_color = Color("#fff0cf")
    sun.light_energy = 1.8
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 120.0
    sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
    add_child(sun)

    mesh_box(Vector3(180, 0.4, 180), Vector3(0, -0.2, 0), mat(Color("#3d493c"), 0.95))
    mesh_box(Vector3(18, 0.10, 180), Vector3(0, 0.05, 0), mat(Color("#202326"), 0.92))
    mesh_box(Vector3(180, 0.10, 18), Vector3(0, 0.06, 0), mat(Color("#202326"), 0.92))

    mesh_box(Vector3(6, 0.18, 180), Vector3(-12, 0.14, 0), mat(Color("#77736b"), 0.85))
    mesh_box(Vector3(6, 0.18, 180), Vector3(12, 0.14, 0), mat(Color("#77736b"), 0.85))
    mesh_box(Vector3(180, 0.18, 6), Vector3(0, 0.15, -12), mat(Color("#77736b"), 0.85))
    mesh_box(Vector3(180, 0.18, 6), Vector3(0, 0.15, 12), mat(Color("#77736b"), 0.85))

    for z: int in range(-80, 81, 10):
        mesh_box(Vector3(0.16, 0.025, 5.0), Vector3(0, 0.12, z), mat(Color("#e8dfbd"), 0.6))
    for x: int in range(-80, 81, 10):
        mesh_box(Vector3(5.0, 0.025, 0.16), Vector3(x, 0.13, 0), mat(Color("#e8dfbd"), 0.6))

    create_detailed_building("BADHARGHAT FAMILY HOME", Vector3(-30, 0, -28), Vector3(16, 8, 13), Color("#c38a62"))
    create_detailed_building("ANI MALL", Vector3(30, 0, -28), Vector3(25, 14, 18), Color("#697b8e"))
    create_detailed_building("RESTAURANT", Vector3(-30, 0, 28), Vector3(15, 6, 12), Color("#8d6047"))
    create_detailed_building("TEA STALL", Vector3(28, 0, 27), Vector3(8, 4, 7), Color("#a77a4c"))
    create_detailed_building("AGARTALA RAILWAY STATION", Vector3(34, 0, 48), Vector3(27, 9, 15), Color("#817d72"))
    create_detailed_building("MAHARAJA BIR BIKRAM AIRPORT", Vector3(-35, 0, 48), Vector3(34, 9, 22), Color("#70818a"))

    create_shop_row(Vector3(-52, 0, -10), 7)
    create_shop_row(Vector3(52, 0, 10), 7)

    for p: Vector3 in [Vector3(-9,0,20), Vector3(15,0,-19), Vector3(-48,0,-5), Vector3(48,0,5), Vector3(-8,0,-48), Vector3(10,0,48)]:
        create_realistic_tree(p)

    create_street_lights()
    create_cars()
    create_road_details()

func create_detailed_building(n: String, pos: Vector3, size: Vector3, base_color: Color) -> void:
    var root: Node3D = Node3D.new()
    root.name = n
    root.position = pos
    add_child(root)
    mesh_box(size, Vector3(0, size.y * 0.5, 0), mat(base_color, 0.72), root)
    mesh_box(Vector3(size.x + 0.5, 0.35, size.z + 0.5), Vector3(0, size.y + 0.18, 0), mat(base_color.darkened(0.18), 0.8), root)

    var floors: int = max(1, int(size.y / 2.8))
    for f: int in range(floors):
        var y: float = 1.25 + f * 2.45
        var windows: int = max(2, int(size.x / 3.2))
        for w: int in range(windows):
            var x: float = -size.x * 0.5 + 1.5 + w * ((size.x - 3.0) / max(1, windows - 1))
            var glass: StandardMaterial3D = mat(Color("#183044"), 0.16, 0.25)
            mesh_box(Vector3(1.45, 1.15, 0.08), Vector3(x, y, -size.z * 0.505), glass, root)
            mesh_box(Vector3(0.10, 1.35, 0.10), Vector3(x - 0.76, y, -size.z * 0.54), mat(Color("#a7a39b"), 0.45), root)
            mesh_box(Vector3(0.10, 1.35, 0.10), Vector3(x + 0.76, y, -size.z * 0.54), mat(Color("#a7a39b"), 0.45), root)

    var sign: MeshInstance3D = mesh_box(Vector3(size.x * 0.68, 0.65, 0.10), Vector3(0, 1.35, -size.z * 0.54), emissive(Color("#274b68"), 0.8), root)
    sign.name = "IlluminatedSign"
    mesh_box(Vector3(size.x * 0.72, 0.20, 1.1), Vector3(0, 2.25, -size.z * 0.62), mat(Color("#45484b"), 0.6, 0.2), root)
    mesh_box(Vector3(1.6, 2.5, 0.12), Vector3(0, 1.3, -size.z * 0.56), mat(Color("#18242b"), 0.12, 0.1), root)
    mesh_cylinder(0.45, 0.9, Vector3(size.x * 0.25, size.y + 0.7, size.z * 0.15), mat(Color("#6c706d"), 0.8, 0.45), root)

func create_shop_row(start: Vector3, count: int) -> void:
    for i: int in range(count):
        var p: Vector3 = start + Vector3(0, 0, i * 9.0 - (count - 1) * 4.5)
        create_detailed_building("SHOP_%02d" % i, p, Vector3(7, 4.5, 6.5), Color("#806b57"))

func create_realistic_tree(pos: Vector3) -> void:
    var root: Node3D = Node3D.new()
    root.position = pos
    add_child(root)
    mesh_cylinder(0.32, 4.2, Vector3(0,2.1,0), mat(Color("#4b3425"), 0.9), root)
    for i: int in range(7):
        var crown: MeshInstance3D = MeshInstance3D.new()
        var sm: SphereMesh = SphereMesh.new()
        sm.radius = 1.5 + (i % 3) * 0.25
        sm.height = sm.radius * 1.65
        sm.material = mat(Color("#23522f"), 0.95)
        crown.mesh = sm
        crown.position = Vector3((i % 3 - 1) * 1.15, 4.0 + (i / 3) * 0.7, ((i * 2) % 3 - 1) * 1.05)
        root.add_child(crown)

func create_street_lights() -> void:
    for x: float in [-8.8, 8.8]:
        for z: int in range(-75, 76, 20):
            mesh_cylinder(0.09, 6.0, Vector3(x,3.0,z), mat(Color("#25292c"), 0.35, 0.65))
            mesh_box(Vector3(1.2,0.16,0.16), Vector3(x + (1.0 if x < 0 else -1.0), 5.8, z), mat(Color("#25292c"), 0.35, 0.65))
            var lamp: OmniLight3D = OmniLight3D.new()
            lamp.position = Vector3(x + (1.5 if x < 0 else -1.5), 5.6, z)
            lamp.light_color = Color("#ffd9a0")
            lamp.light_energy = 3.2
            lamp.omni_range = 10.0
            add_child(lamp)

func create_cars() -> void:
    var positions: Array[Vector3] = [
        Vector3(-4,0.65,-35), Vector3(4,0.65,-10), Vector3(-4,0.65,22),
        Vector3(35,0.65,-4), Vector3(-35,0.65,4)
    ]
    for i: int in range(positions.size()):
        create_car(positions[i], i == 0)

func create_car(pos: Vector3, scorpio: bool = false) -> void:
    var root: Node3D = Node3D.new()
    root.position = pos
    add_child(root)
    var body_color: Color = Color("#20252a") if scorpio else Color("#b53f36")
    mesh_box(Vector3(3.5, 0.8, 1.65), Vector3(0,0.65,0), mat(body_color,0.35,0.45), root)
    mesh_box(Vector3(2.2, 0.72, 1.45), Vector3(0,1.18,-0.05), mat(Color("#1a2933"),0.12,0.35), root)
    for x: float in [-1.25,1.25]:
        for z: float in [-0.63,0.63]:
            var wheel: MeshInstance3D = MeshInstance3D.new()
            var wm: CylinderMesh = CylinderMesh.new()
            wm.top_radius = 0.38
            wm.bottom_radius = 0.38
            wm.height = 0.22
            wm.material = mat(Color("#101112"),0.95)
            wheel.mesh = wm
            wheel.rotation_degrees = Vector3(90,0,0)
            wheel.position = Vector3(x,0.38,z)
            root.add_child(wheel)
    mesh_box(Vector3(0.55,0.25,0.08), Vector3(0,0.72,-0.86), emissive(Color("#f7d47a"),1.4), root)

func create_road_details() -> void:
    for z: int in range(-80,81,20):
        mesh_box(Vector3(0.6,0.12,0.6), Vector3(-9.2,0.25,z), mat(Color("#54585a"),0.8))
        mesh_box(Vector3(0.6,0.12,0.6), Vector3(9.2,0.25,z), mat(Color("#54585a"),0.8))

func create_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    var body: Node3D = Node3D.new()
    player.add_child(body)
    mesh_cylinder(0.38, 1.05, Vector3(0,1.05,0), mat(Color("#26384d"),0.62), body)
    mesh_cylinder(0.22, 0.45, Vector3(0,1.75,0), mat(Color("#a86f4f"),0.7), body)

    var head: MeshInstance3D = MeshInstance3D.new()
    var sphere: SphereMesh = SphereMesh.new()
    sphere.radius = 0.24
    sphere.height = 0.48
    sphere.material = mat(Color("#a86f4f"),0.72)
    head.mesh = sphere
    head.position = Vector3(0,2.05,0)
    body.add_child(head)

    for x: float in [-0.18,0.18]:
        mesh_cylinder(0.10, 0.85, Vector3(x,0.38,0), mat(Color("#171b22"),0.75), body)
        mesh_cylinder(0.10, 0.85, Vector3(x,1.05,0), mat(Color("#314762"),0.7), body)

    var shape: CollisionShape3D = CollisionShape3D.new()
    var cs: CapsuleShape3D = CapsuleShape3D.new()
    cs.height = 2.0
    cs.radius = 0.38
    shape.shape = cs
    shape.position.y = 1.0
    player.add_child(shape)
    player.position = Vector3(0,0.15,8)
    add_child(player)

    camera = Camera3D.new()
    camera.current = true
    camera.fov = 68.0
    camera.position = Vector3(0,3.6,7.8)
    player.add_child(camera)

func _physics_process(delta: float) -> void:
    if not player:
        return
    var input_vector: Vector2 = move_input
    if input_vector.length() < 0.05:
        input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    var dir: Vector3 = Vector3(input_vector.x,0,input_vector.y)
    dir = dir.rotated(Vector3.UP, yaw).normalized()
    var current_speed: float = sprint_speed if Input.is_action_pressed("ui_accept") else speed
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
    pitch = clamp(pitch + look_input.y * delta * 1.8, -35.0, 20.0)
    camera.rotation_degrees = Vector3(pitch,0,0)
    camera.position = Vector3(0,3.6,7.8)

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
        var center: Vector2 = Vector2(120, get_viewport().size.y-120)
        if event.index == joystick_touch:
            move_input = ((event.position-center)/90.0).limit_length(1.0)
        elif event.index == look_touch:
            look_input = event.relative/70.0
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        look_input = event.relative/70.0

func create_ui() -> void:
    var layer: CanvasLayer = CanvasLayer.new()
    add_child(layer)

    var title: Label = Label.new()
    title.text = "PANDAL HOPPING\nAN AGARTALA STORY"
    title.position = Vector2(28,24)
    title.add_theme_font_size_override("font_size",24)
    title.modulate = Color("#f4f1e8")
    layer.add_child(title)

    var hint: Label = Label.new()
    hint.text = "3D PROTOTYPE • BADHARGHAT / AGARTALA\nTouch left to move • Touch right to look"
    hint.position = Vector2(28,88)
    hint.add_theme_font_size_override("font_size",14)
    hint.modulate = Color("#c4ccd0")
    layer.add_child(hint)

    var brand: Label = Label.new()
    brand.text = "A GAME BY ANI STUDIO"
    brand.position = Vector2(28,150)
    brand.add_theme_font_size_override("font_size",12)
    brand.modulate = Color("#9aa8ff")
    layer.add_child(brand)
