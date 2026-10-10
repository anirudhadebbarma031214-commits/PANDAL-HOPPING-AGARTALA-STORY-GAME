extends Node

# Independent startup recovery for Android emulators.
# If the scripted loading UI survives for 8 seconds, reveal the fallback scene
# and ensure a camera/environment exist so the player does not see a blank screen.
func _ready() -> void:
    await get_tree().create_timer(8.0).timeout

    var scene_root := get_parent()
    if scene_root == null:
        return

    var loading_layer := scene_root.get_node_or_null("BootLoadingLayer")
    if loading_layer != null and is_instance_valid(loading_layer):
        loading_layer.queue_free()

    var active_camera := get_viewport().get_camera_3d()
    if active_camera == null:
        var fallback_camera := scene_root.get_node_or_null("FallbackCamera") as Camera3D
        if fallback_camera == null:
            fallback_camera = Camera3D.new()
            fallback_camera.name = "EmergencyCamera"
            fallback_camera.position = Vector3(0, 7, 18)
            fallback_camera.rotation_degrees = Vector3(-18, 0, 0)
            scene_root.add_child(fallback_camera)
        fallback_camera.current = true

    if scene_root.get_node_or_null("EmergencyEnvironment") == null:
        var world_environment := WorldEnvironment.new()
        world_environment.name = "EmergencyEnvironment"
        var environment := Environment.new()
        environment.background_mode = Environment.BG_COLOR
        environment.background_color = Color("#172235")
        environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
        environment.ambient_light_color = Color("#c0c9d8")
        environment.ambient_light_energy = 0.8
        world_environment.environment = environment
        scene_root.add_child(world_environment)

    if scene_root.get_node_or_null("EmergencyStartupNotice") == null:
        var notice_layer := CanvasLayer.new()
        notice_layer.name = "EmergencyStartupNotice"
        notice_layer.layer = 110
        scene_root.add_child(notice_layer)
        var notice := Label.new()
        notice.text = "PANDAL HOPPING  •  SAFE MODE\nStartup recovery active"
        notice.position = Vector2(24, 24)
        notice.add_theme_font_size_override("font_size", 18)
        notice.modulate = Color("#ffffff")
        notice_layer.add_child(notice)
