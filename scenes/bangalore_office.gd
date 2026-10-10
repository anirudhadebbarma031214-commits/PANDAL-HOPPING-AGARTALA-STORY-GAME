extends Node3D
## Procedural cinematic staging scene for the Bangalore opening.

func _ready() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#080e1c")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#5e7195")
    env.ambient_light_energy = 0.6
    world.environment = env
    add_child(world)

    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35, -25, 0)
    light.light_energy = 0.55
    add_child(light)

    _box(Vector3(0, -0.2, 0), Vector3(24, 0.4, 24), Color("#202733"))
    _box(Vector3(0, 6, -10), Vector3(24, 12, 0.3), Color("#111b2a"))
    # Night skyline panels behind office windows.
    for i in range(8):
        _box(Vector3(-10.0 + i * 2.8, 3.0 + float(i % 3), -9.7), Vector3(1.4, 5.5, 0.12), Color("#142d49"))
    # Desk, monitor and a tired employee silhouette.
    _box(Vector3(0, 1.0, 0), Vector3(4.2, 0.18, 2.0), Color("#443a34"))
    _box(Vector3(0, 1.75, -0.35), Vector3(1.25, 0.85, 0.12), Color("#09111e"))
    _box(Vector3(0, 1.77, -0.27), Vector3(1.08, 0.65, 0.025), Color("#28435a"))
    _box(Vector3(-0.7, 0.55, 0.25), Vector3(0.35, 1.0, 0.35), Color("#283a4e"))
    _box(Vector3(-0.7, 1.25, 0.25), Vector3(0.32, 0.32, 0.32), Color("#9c6d51"))

    var camera := Camera3D.new()
    camera.position = Vector3(5.8, 3.2, 8.8)
    camera.look_at(Vector3(0, 1.2, 0))
    camera.current = true
    add_child(camera)

    var title := Label3D.new()
    title.text = "BANGALORE • 11:48 PM"
    title.position = Vector3(-4.5, 4.3, -2.5)
    title.font_size = 44
    title.modulate = Color("#d8e5ff")
    add_child(title)

func _box(pos: Vector3, size: Vector3, color: Color) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.75
    mesh.material = material
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    add_child(node)
