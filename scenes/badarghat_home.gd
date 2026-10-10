extends Node3D
## Warm, modest Bengali family home interior in Badarghat.

func _ready() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#241b17")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#ffd4a1")
    env.ambient_light_energy = 0.85
    world.environment = env
    add_child(world)

    var light := OmniLight3D.new()
    light.position = Vector3(0, 3.2, 0)
    light.light_color = Color("#ffcc8a")
    light.light_energy = 1.5
    light.omni_range = 12
    add_child(light)

    _box(Vector3(0, -0.2, 0), Vector3(10, 0.4, 9), Color("#9b785d"))
    _box(Vector3(0, 2.2, -4.4), Vector3(10, 4.8, 0.25), Color("#e4d1b7"))
    _box(Vector3(-4.9, 2.2, 0), Vector3(0.25, 4.8, 9), Color("#dfc9ae"))
    _box(Vector3(4.9, 2.2, 0), Vector3(0.25, 4.8, 9), Color("#dfc9ae"))
    _box(Vector3(0, 4.6, 0), Vector3(10, 0.25, 9), Color("#6f4e3a"))
    # Sofa and low tea table.
    _box(Vector3(0, 0.55, -1.3), Vector3(3.2, 0.8, 0.9), Color("#6e4538"))
    _box(Vector3(0, 0.32, 0.6), Vector3(1.7, 0.16, 1.0), Color("#694a32"))
    # Family photo frame on the wall.
    _box(Vector3(0, 2.8, -4.22), Vector3(1.3, 0.9, 0.08), Color("#583a2a"))
    _box(Vector3(0, 2.8, -4.16), Vector3(1.08, 0.68, 0.03), Color("#d0a579"))
    # Puja flower decoration.
    for i in range(5):
        _box(Vector3(-2.0 + i, 3.4, -4.15), Vector3(0.18, 0.18, 0.08), Color("#c84b35"))

    var camera := Camera3D.new()
    camera.position = Vector3(0, 2.1, 7.2)
    camera.look_at(Vector3(0, 1.5, -0.4))
    camera.current = true
    add_child(camera)

    var sign := Label3D.new()
    sign.text = "BADARGHAT • HOME"
    sign.position = Vector3(-2.3, 3.8, -4.15)
    sign.font_size = 28
    sign.modulate = Color("#4a3023")
    add_child(sign)

func _box(pos: Vector3, size: Vector3, color: Color) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.85
    mesh.material = material
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    add_child(node)
