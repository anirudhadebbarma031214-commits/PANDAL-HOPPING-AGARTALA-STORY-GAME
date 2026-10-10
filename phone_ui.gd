extends CanvasLayer
## Lightweight in-game phone UI. Attach to a CanvasLayer or instantiate as a child.

var phone_open := false
var panel: PanelContainer
var content: VBoxContainer

func _ready() -> void:
    layer = 20
    _build_phone()

func _build_phone() -> void:
    var toggle := Button.new()
    toggle.text = "▣  ANI PHONE"
    toggle.position = Vector2(-176, 28)
    toggle.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    toggle.size = Vector2(148, 48)
    toggle.pressed.connect(_toggle_phone)
    add_child(toggle)

    panel = PanelContainer.new()
    panel.position = Vector2(-350, 90)
    panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    panel.size = Vector2(320, 540)
    panel.visible = false
    add_child(panel)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    panel.add_child(column)
    var heading := Label.new()
    heading.text = "ANI  •  PHONE"
    heading.add_theme_font_size_override("font_size", 22)
    column.add_child(heading)
    var tagline := Label.new()
    tagline.text = "AGARTALA  /  OCTOBER"
    tagline.add_theme_font_size_override("font_size", 11)
    column.add_child(tagline)

    for item in [
        ["CALLS", "Ma • 2 missed calls"],
        ["MESSAGES", "Ma: Pujor age bari phire ay."],
        ["MAP", "Badarghat • Agartala"],
        ["ANI PAY", "Balance: ₹18,500"],
        ["LEGAL", "No pending traffic notices"]
    ]:
        var card := PanelContainer.new()
        column.add_child(card)
        var text := Label.new()
        text.text = item[0] + "\n" + item[1]
        text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        card.add_child(text)

    var close := Button.new()
    close.text = "CLOSE PHONE"
    close.pressed.connect(_toggle_phone)
    column.add_child(close)

func _toggle_phone() -> void:
    phone_open = not phone_open
    panel.visible = phone_open
