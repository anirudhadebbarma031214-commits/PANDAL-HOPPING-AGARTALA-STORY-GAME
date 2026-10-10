extends Node3D
## Optional modular landmark builder for additional Agartala areas.
## The current main.gd already generates its own city map.

func build_badarghat_world() -> void:
    _box(Vector3(0, -0.2, 0), Vector3(100, 0.4, 100), Color("#53624b"))
    _box(Vector3(0, 0.02, 0), Vector3(9, 0.12, 100), Color("#282b30"))
    _box(Vector3(-8, 0.12, 0), Vector3(3, 0.12, 100), Color("#aaa294"))
    _building("Badarghat Family Home", Vector3(-18, 0, -12), Vector3(12, 6, 10), Color("#bd8d6c"))
    _building("Local Market", Vector3(18, 0, -10), Vector3(18, 5, 9), Color("#9a7050"))
    _building("Tea Stall", Vector3(-17, 0, 14), Vector3(7, 3.5, 6), Color("#c69a5d"))
    _build_puja_pandal(Vector3(0, 0, -34))

func _build_puja_pandal(origin: Vector3) -> void:
    _box(origin + Vector3(0, 0.3, 0), Vector3(18, 0.6, 13), Color("#b78c5d"))
    _box(origin + Vector3(0, 3.0, -4), Vector3(15, 5.4, 0.6), Color("#d5a66b"))
    _box(origin + Vector3(0, 5.9, -4), Vector3(18, 0.6, 1.2), Color("#9f4d3d"))
    for x in [-6.0, -3.0, 0.0, 3.0, 6.0]:
        _box(origin + Vector3(x, 2.0, -3.4), Vector3(0.12, 3.6, 0.12), Color("#f2d49a"))
    _box(origin + Vector3(0, 2.1, -3.0), Vector3(2.5, 3.0, 0.35), Color("#d5a53e"))

func _building(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
    _box(pos + Vector3(0, size.y * 0.5, 0), size, color)
    var sign := Label3D.new()
    sign.text = label
    sign.position = pos + Vector3(0, size.y + 0.4, -size.z * 0.5)
    sign.font_size = 28
    sign.modulate = Color("#fff0d7")
    add_child(sign)

func _box(pos: Vector3, size: Vector3, color: Color) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.82
    mesh.material = material
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    add_child(node)
