extends CanvasLayer

var paused := false
var panel: PanelContainer

func _ready() -> void:
    layer = 30
    process_mode = Node.PROCESS_MODE_ALWAYS
    var pause_button := Button.new()
    pause_button.text = "Ⅱ"
    pause_button.position = Vector2(-70, 28)
    pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    pause_button.size = Vector2(48, 48)
    pause_button.pressed.connect(toggle_pause)
    add_child(pause_button)

    panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-190, -170)
    panel.size = Vector2(380, 340)
    panel.visible = false
    panel.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(panel)

    var column := VBoxContainer.new()
    panel.add_child(column)
    var title := Label.new()
    title.text = "PANDAL HOPPING"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    column.add_child(title)
    var resume := Button.new()
    resume.text = "RESUME STORY"
    resume.pressed.connect(toggle_pause)
    column.add_child(resume)
    var hint := Label.new()
    hint.text = "Sometimes you have to leave home\nto realize what home means."
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(hint)

func toggle_pause() -> void:
    paused = not paused
    get_tree().paused = paused
    panel.visible = paused

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        toggle_pause()
