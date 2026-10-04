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

var loading_layer: CanvasLayer
var loading_root: ColorRect
var loading_bar: ColorRect
var loading_status: Label

func _ready() -> void:
    create_loading_screen()
    await get_tree().process_frame
    set_loading_progress(0.12, "Loading Agartala...")
    create_world()
    create_living_city_systems()
    await get_tree().process_frame
    set_loading_progress(0.42, "Building the city...")
    create_player()
    await get_tree().process_frame
    set_loading_progress(0.68, "Preparing player controls...")
    create_ui()
    await get_tree().process_frame
    set_loading_progress(0.88, "Finalizing the world...")
    await get_tree().create_timer(0.65).timeout
    set_loading_progress(1.0, "Welcome to Agartala")
    await get_tree().create_timer(0.55).timeout
    if is_instance_valid(loading_root):
        loading_root.queue_free()
    if is_instance_valid(loading_layer):
        loading_layer.queue_free()

func create_loading_screen() -> void:
    loading_layer = CanvasLayer.new()
    loading_layer.layer = 100
    add_child(loading_layer)

    loading_root = ColorRect.new()
    loading_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    loading_root.color = Color("#020307")
    loading_layer.add_child(loading_root)

    var image_panel: ColorRect = ColorRect.new()
    image_panel.position = Vector2(0, 0)
    image_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    image_panel.color = Color(0.015, 0.02, 0.035, 1.0)
    loading_root.add_child(image_panel)

    var glow: ColorRect = ColorRect.new()
    glow.position = Vector2(0, 0)
    glow.set_anchors_preset(Control.PRESET_FULL_RECT)
    glow.color = Color(0.035, 0.055, 0.11, 0.28)
    loading_root.add_child(glow)

    var brand: Label = Label.new()
    brand.text = "A GAME BY ANI STUDIO"
    brand.position = Vector2(42, 42)
    brand.add_theme_font_size_override("font_size", 16)
    brand.modulate = Color("#aebcff")
    loading_root.add_child(brand)

    var title: Label = Label.new()
    title.text = "PANDAL HOPPING"
    title.position = Vector2(42, 150)
    title.add_theme_font_size_override("font_size", 42)
    title.modulate = Color("#f5f3ec")
    loading_root.add_child(title)

    var subtitle: Label = Label.new()
    subtitle.text = "AN AGARTALA STORY"
    subtitle.position = Vector2(45, 204)
    subtitle.add_theme_font_size_override("font_size", 22)
    subtitle.modulate = Color("#d6dce4")
    loading_root.add_child(subtitle)

    var location: Label = Label.new()
    location.text = "AGARTALA • TRIPURA"
    location.position = Vector2(45, 246)
    location.add_theme_font_size_override("font_size", 13)
    location.modulate = Color("#8795a5")
    loading_root.add_child(location)

    var tip: Label = Label.new()
    tip.text = "THE CITY REMEMBERS YOU."
    tip.position = Vector2(45, 0)
    tip.set_anchors_preset(Control.PRESET_CENTER_LEFT)
    tip.position.y = 315
    tip.add_theme_font_size_override("font_size", 18)
    tip.modulate = Color("#e5e7eb")
    loading_root.add_child(tip)

    loading_status = Label.new()
    loading_status.text = "Loading..."
    loading_status.position = Vector2(45, 0)
    loading_status.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    loading_status.position = Vector2(45, -145)
    loading_status.add_theme_font_size_override("font_size", 15)
    loading_status.modulate = Color("#aeb7c3")
    loading_root.add_child(loading_status)

    var track: ColorRect = ColorRect.new()
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

    var hint: Label = Label.new()
    hint.text = "Loading the world • Please wait"
    hint.position = Vector2(45, 0)
    hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    hint.position = Vector2(45, -75)
    hint.add_theme_font_size_override("font_size", 12)
    hint.modulate = Color("#697586")
    loading_root.add_child(hint)

func set_loading_progress(value: float, status: String) -> void:
    if not is_instance_valid(loading_bar):
        return
    var clamped: float = clamp(value, 0.0, 1.0)
    loading_bar.size.x = 520.0 * clamped
    if is_instance_valid(loading_status):
        loading_status.text = status + "  " + str(int(clamped * 100.0)) + "%"


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

func create_living_city_systems() -> void:
    create_traffic_system()
    create_pedestrian_system()
    create_mission_ui()
    create_phone_ui()
    create_weather_system()
    create_map_ui()

func create_traffic_system() -> void:
    var traffic: Node3D = Node3D.new()
    traffic.name = "TRAFFIC_SYSTEM"
    add_child(traffic)
    for i: int in range(8):
        var p: Vector3 = Vector3(-78.0 + float(i % 6) * 31.0, 0.65, -62.0 + float(i / 6) * 124.0)
        create_car(p, i % 5 == 0)

func create_pedestrian_system() -> void:
    var pedestrians: Node3D = Node3D.new()
    pedestrians.name = "PEDESTRIAN_SYSTEM"
    add_child(pedestrians)
    for i: int in range(10):
        var p: Vector3 = Vector3(-70.0 + float((i * 17) % 140), 0.0, -75.0 + float((i * 29) % 150))
        var person: Node3D = Node3D.new()
        person.name = "NPC_%02d" % i
        person.position = p
        pedestrians.add_child(person)
        mesh_cylinder(0.22, 1.05, Vector3(0, 0.95, 0), mat(Color("#34465a"), 0.78), person)
        mesh_cylinder(0.14, 0.32, Vector3(0, 1.65, 0), mat(Color("#a87456"), 0.75), person)
        var head: MeshInstance3D = MeshInstance3D.new()
        var sphere: SphereMesh = SphereMesh.new()
        sphere.radius = 0.15
        sphere.height = 0.30
        sphere.material = mat(Color("#a87456"), 0.75)
        head.mesh = sphere
        head.position = Vector3(0, 1.9, 0)
        person.add_child(head)

func create_mission_ui() -> void:
    var layer: CanvasLayer = CanvasLayer.new()
    layer.name = "MissionUI"
    layer.layer = 10
    add_child(layer)
    var panel: ColorRect = ColorRect.new()
    panel.position = Vector2(28, 205)
    panel.size = Vector2(360, 92)
    panel.color = Color(0.02, 0.025, 0.04, 0.86)
    layer.add_child(panel)
    var title: Label = Label.new()
    title.text = "CURRENT MISSION"
    title.position = Vector2(18, 12)
    title.add_theme_font_size_override("font_size", 12)
    title.modulate = Color("#9eacff")
    panel.add_child(title)
    var mission: Label = Label.new()
    mission.text = "THE CALL FROM HOME\nGo home to Badharghat"
    mission.position = Vector2(18, 34)
    mission.add_theme_font_size_override("font_size", 16)
    mission.modulate = Color("#f0f2f5")
    panel.add_child(mission)

func create_phone_ui() -> void:
    var layer: CanvasLayer = CanvasLayer.new()
    layer.name = "PhoneUI"
    layer.layer = 12
    add_child(layer)
    var phone: Button = Button.new()
    phone.name = "PhoneButton"
    phone.text = "PHONE"
    phone.position = Vector2(0, 0)
    phone.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    phone.position = Vector2(-150, 28)
    phone.size = Vector2(120, 52)
    phone.add_theme_font_size_override("font_size", 14)
    layer.add_child(phone)
    phone.pressed.connect(_toggle_phone)
    var panel: ColorRect = ColorRect.new()
    panel.name = "PhonePanel"
    panel.position = Vector2(0, 0)
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-180, -260)
    panel.size = Vector2(360, 520)
    panel.color = Color("#0b1018")
    panel.visible = false
    layer.add_child(panel)
    var label: Label = Label.new()
    label.text = "ANI PHONE\n\nMAP     CALLS     MESSAGES\n\nANI PAY     CAMERA\n\nTraffic & legal notices"
    label.position = Vector2(28, 30)
    label.add_theme_font_size_override("font_size", 20)
    label.modulate = Color("#e8edf4")
    panel.add_child(label)

func _toggle_phone() -> void:
    var layer: CanvasLayer = get_node_or_null("PhoneUI") as CanvasLayer
    if not layer:
        return
    var panel: ColorRect = layer.get_node_or_null("PhonePanel") as ColorRect
    if panel:
        panel.visible = not panel.visible

func create_weather_system() -> void:
    var weather: GPUParticles3D = GPUParticles3D.new()
    weather.name = "RAIN_SYSTEM"
    weather.amount = 260
    weather.lifetime = 1.5
    weather.position = Vector3(0, 14, 0)
    weather.visibility_aabb = AABB(Vector3(-90, -14, -90), Vector3(180, 30, 180))
    var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
    process.direction = Vector3(0, -1, 0)
    process.initial_velocity_min = 14.0
    process.initial_velocity_max = 22.0
    process.gravity = Vector3(0, -5, 0)
    process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    process.emission_box_extents = Vector3(85, 1, 85)
    weather.process_material = process
    var mesh: BoxMesh = BoxMesh.new()
    mesh.size = Vector3(0.025, 0.5, 0.025)
    mesh.material = mat(Color("#9eb6d0"), 0.4)
    weather.draw_pass_1 = mesh
    weather.emitting = false
    add_child(weather)
    var button: Button = Button.new()
    button.text = "RAIN"
    button.position = Vector2(28, 320)
    button.size = Vector2(110, 46)
    button.add_theme_font_size_override("font_size", 13)
    var layer: CanvasLayer = CanvasLayer.new()
    layer.layer = 11
    add_child(layer)
    layer.add_child(button)
    button.pressed.connect(func() -> void:
        weather.emitting = not weather.emitting
    )

func create_map_ui() -> void:
    var layer: CanvasLayer = CanvasLayer.new()
    layer.name = "MapUI"
    layer.layer = 9
    add_child(layer)
    var map_button: Button = Button.new()
    map_button.text = "MAP"
    map_button.position = Vector2(28, 380)
    map_button.size = Vector2(110, 46)
    map_button.add_theme_font_size_override("font_size", 13)
    layer.add_child(map_button)
    var map_panel: ColorRect = ColorRect.new()
    map_panel.name = "MapPanel"
    map_panel.position = Vector2(28, 435)
    map_panel.size = Vector2(390, 230)
    map_panel.color = Color(0.025, 0.04, 0.06, 0.94)
    map_panel.visible = false
    layer.add_child(map_panel)
    var map_text: Label = Label.new()
    map_text.text = "AGARTALA WORLD MAP\n\n✈ MBB AIRPORT     🚆 RAILWAY STATION\n🏠 BADHARGHAT     🏬 MALL\n🏛 UJJAYANTA PALACE\n🛕 TEMPLE        👮 POLICE HQ\n\nUDAIPUR → 230m SOUTH ROAD"
    map_text.position = Vector2(18, 18)
    map_text.add_theme_font_size_override("font_size", 15)
    map_text.modulate = Color("#e5e9ef")
    map_panel.add_child(map_text)
    map_button.pressed.connect(func() -> void:
        map_panel.visible = not map_panel.visible
    )

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
    env.glow_enabled = false
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
    sun.directional_shadow_max_distance = 70.0
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

    create_shop_row(Vector3(-52, 0, -10), 4)
    create_shop_row(Vector3(52, 0, 10), 4)

    for p: Vector3 in [Vector3(-9,0,20), Vector3(15,0,-19), Vector3(-48,0,-5), Vector3(48,0,5), Vector3(-8,0,-48), Vector3(10,0,48)]:
        create_realistic_tree(p)

    create_street_lights()
    create_cars()
    create_scorpio()
    create_agartala_landmarks()
    create_udaipur_region()
    create_world_assets()
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
        for z: int in range(-75, 76, 38):
            mesh_cylinder(0.09, 6.0, Vector3(x,3.0,z), mat(Color("#25292c"), 0.35, 0.65))
            mesh_box(Vector3(1.2,0.16,0.16), Vector3(x + (1.0 if x < 0 else -1.0), 5.8, z), mat(Color("#25292c"), 0.35, 0.65))
            if z == -75 or z == 1 or z == 77:
                var lamp: OmniLight3D = OmniLight3D.new()
                lamp.position = Vector3(x + (1.5 if x < 0 else -1.5), 5.6, z)
                lamp.light_color = Color("#ffd9a0")
                lamp.light_energy = 1.6
                lamp.omni_range = 7.0
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
func create_scorpio() -> void:
    var root: Node3D = Node3D.new()
    root.name = "PLAYER_SCORPIO"
    root.position = Vector3(7, 0.0, 8)
    add_child(root)
    var black: StandardMaterial3D = mat(Color("#111318"), 0.24, 0.55)
    var glass: StandardMaterial3D = mat(Color("#10202b"), 0.08, 0.45)
    mesh_box(Vector3(4.65, 1.05, 1.95), Vector3(0, 0.82, 0), black, root)
    mesh_box(Vector3(3.0, 1.15, 1.72), Vector3(0, 1.72, -0.05), black, root)
    mesh_box(Vector3(2.55, 0.72, 1.78), Vector3(0, 1.78, -0.14), glass, root)
    mesh_box(Vector3(0.22, 1.15, 1.82), Vector3(-2.05, 1.45, 0), black, root)
    mesh_box(Vector3(0.22, 1.15, 1.82), Vector3(2.05, 1.45, 0), black, root)
    for x: float in [-1.62, 1.62]:
        for z: float in [-0.78, 0.78]:
            var wheel: MeshInstance3D = MeshInstance3D.new()
            var wm: CylinderMesh = CylinderMesh.new()
            wm.top_radius = 0.48
            wm.bottom_radius = 0.48
            wm.height = 0.28
            wm.material = mat(Color("#08090a"), 0.96)
            wheel.mesh = wm
            wheel.rotation_degrees = Vector3(90, 0, 0)
            wheel.position = Vector3(x, 0.45, z)
            root.add_child(wheel)
    mesh_box(Vector3(0.65, 0.25, 0.08), Vector3(-1.45, 0.78, -1.02), emissive(Color("#fff1c1"), 2.0), root)
    mesh_box(Vector3(0.65, 0.25, 0.08), Vector3(1.45, 0.78, -1.02), emissive(Color("#fff1c1"), 2.0), root)
    mesh_box(Vector3(2.0, 0.16, 0.10), Vector3(0, 0.72, 1.02), emissive(Color("#e33d38"), 1.4), root)
    var label: Label = Label.new()
    label.text = "SCORPIO"
    label.position = Vector2(0, -30)
    label.add_theme_font_size_override("font_size", 11)
    label.modulate = Color("#d6dbe3")
    var marker: Sprite3D = Sprite3D.new()
    marker.name = "VehicleMarker"
    root.add_child(marker)

func create_agartala_landmarks() -> void:
    create_landmark("UJJAYANTA PALACE", Vector3(-72, 0, -55), Vector3(30, 12, 22), Color("#e8e4d6"))
    create_landmark("HERITAGE PARK", Vector3(-92, 0, -20), Vector3(24, 5, 18), Color("#486b4e"))
    create_landmark("TRIPURA STATE MUSEUM", Vector3(-68, 0, -82), Vector3(20, 8, 14), Color("#d6d0bf"))
    create_landmark("JAGANNATH TEMPLE", Vector3(-40, 0, -65), Vector3(13, 10, 13), Color("#c7a36a"))
    create_landmark("TRIPURA POLICE HQ", Vector3(70, 0, -55), Vector3(22, 8, 14), Color("#68717b"))
    create_landmark("MALL / CITY CENTRE", Vector3(75, 0, -20), Vector3(30, 12, 20), Color("#657b91"))
    create_landmark("BADHARGHAT", Vector3(0, 0, 75), Vector3(34, 7, 25), Color("#9a775d"))
    create_landmark("AGARTALA BUS TERMINAL", Vector3(55, 0, 35), Vector3(28, 7, 18), Color("#6c756f"))
    create_landmark("AGARTALA RAILWAY STATION", Vector3(105, 0, 45), Vector3(36, 10, 20), Color("#77746d"))
    create_landmark("MBB AIRPORT", Vector3(-115, 0, 50), Vector3(45, 10, 28), Color("#73828b"))

func create_landmark(n: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var root: Node3D = Node3D.new()
    root.name = n
    root.position = pos
    add_child(root)
    mesh_box(size, Vector3(0, size.y * 0.5, 0), mat(color, 0.68), root)
    mesh_box(Vector3(size.x * 0.78, 0.5, 0.18), Vector3(0, size.y * 0.62, -size.z * 0.52), emissive(Color("#253e67"), 0.7), root)
    if "PALACE" in n:
        for x: float in [-9.0, 0.0, 9.0]:
            mesh_cylinder(2.1, 7.0, Vector3(x, size.y + 3.0, 0), color.lightened(0.12), root)
    if "TEMPLE" in n:
        mesh_cylinder(3.0, 8.0, Vector3(0, size.y + 4.0, 0), color.lightened(0.1), root)

func create_udaipur_region() -> void:
    var region: Node3D = Node3D.new()
    region.name = "UDAIPUR_TRIPURA_REGION"
    region.position = Vector3(0, 0, 230)
    add_child(region)
    mesh_box(Vector3(220, 0.35, 180), Vector3(0, -0.2, 0), mat(Color("#405b43"), 0.98), region)
    mesh_box(Vector3(18, 0.12, 180), Vector3(0, 0.05, 0), mat(Color("#303336"), 0.9), region)
    for z: int in range(-80, 81, 12):
        mesh_box(Vector3(0.16, 0.025, 5.5), Vector3(0, 0.14, z), mat(Color("#e5d9ae"), 0.65), region)
    create_landmark_at(region, "TRIPURESWARI TEMPLE", Vector3(-42, 0, -42), Vector3(20, 11, 18), Color("#9c7354"))
    create_landmark_at(region, "UDAIPUR LAKE", Vector3(42, 0, -28), Vector3(55, 0.15, 38), Color("#365f70"))
    create_landmark_at(region, "UDAIPUR MARKET", Vector3(-35, 0, 28), Vector3(30, 6, 20), Color("#80634e"))
    create_landmark_at(region, "UDAIPUR TOWN", Vector3(38, 0, 40), Vector3(42, 8, 30), Color("#77756d"))
    create_landmark_at(region, "GOMATI RIVER", Vector3(0, 0, 72), Vector3(150, 0.15, 20), Color("#315b68"))

func create_landmark_at(parent: Node3D, n: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var root: Node3D = Node3D.new()
    root.name = n
    root.position = pos
    parent.add_child(root)
    mesh_box(size, Vector3(0, size.y * 0.5, 0), mat(color, 0.82), root)

func create_world_assets() -> void:
    for i: int in range(12):
        var x: float = -130.0 + float((i * 37) % 260)
        var z: float = -110.0 + float((i * 61) % 220)
        create_realistic_tree(Vector3(x, 0, z))
    for i: int in range(8):
        var p: Vector3 = Vector3(-120 + (i % 9) * 30, 0.6, -100 + (i / 9) * 190)
        create_car(p, i == 2)

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
