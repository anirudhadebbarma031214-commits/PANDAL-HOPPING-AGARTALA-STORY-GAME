extends CanvasLayer
## Story beat director with Bengali dialogue and English subtitles.
## Instantiate from the main scene and call start_opening_cutscene().

signal beat_finished(beat_id: String)
var beats: Array[Dictionary] = [
    {"id":"office_1","speaker":"NARRATOR","bn":"রাত অনেক হয়েছে।","en":"It's late at the office.","seconds":3.0},
    {"id":"mother_call","speaker":"MA","bn":"বাবা, মহালয়ার দিন বাড়ি আয়। পুজোয় তোকে খুব মিস করি।","en":"Come home for Mahalaya, son. We miss you during Puja.","seconds":5.0},
    {"id":"son_reply","speaker":"SON","bn":"মা, কাজের চাপ খুব বেশি। চেষ্টা করছি।","en":"Ma, work is overwhelming. I'll try.","seconds":4.0},
    {"id":"father_pause","speaker":"BABA","bn":"ঠিক আছে বাবা। নিজের খেয়াল রাখিস।","en":"All right, son. Take care of yourself.","seconds":4.0},
    {"id":"photo","speaker":"NARRATOR","bn":"পুরনো ছবিটা তাকে বাড়ির কথা মনে করিয়ে দিল।","en":"An old photograph reminds him what home means.","seconds":4.0}
]
var card: PanelContainer
var speaker_label: Label
var bengali_label: Label
var subtitle_label: Label
var active := false

func _ready() -> void:
    layer = 40
    _make_overlay()

func _make_overlay() -> void:
    card = PanelContainer.new()
    card.anchor_left = 0.03
    card.anchor_top = 0.76
    card.anchor_right = 0.97
    card.anchor_bottom = 0.97
    card.offset_left = 0
    card.offset_top = 0
    card.offset_right = 0
    card.offset_bottom = 0
    card.visible = false
    add_child(card)
    var column := VBoxContainer.new()
    card.add_child(column)
    speaker_label = Label.new()
    speaker_label.add_theme_font_size_override("font_size", 16)
    column.add_child(speaker_label)
    bengali_label = Label.new()
    bengali_label.add_theme_font_size_override("font_size", 24)
    bengali_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(bengali_label)
    subtitle_label = Label.new()
    subtitle_label.add_theme_font_size_override("font_size", 18)
    subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(subtitle_label)

func start_opening_cutscene() -> void:
    if active:
        return
    active = true
    card.visible = true
    for beat in beats:
        speaker_label.text = str(beat["speaker"])
        bengali_label.text = str(beat["bn"])
        subtitle_label.text = str(beat["en"])
        await get_tree().create_timer(clampf(float(beat["seconds"]), 1.0, 8.0)).timeout
    card.visible = false
    active = false
    beat_finished.emit("opening_call_from_home")

func show_dialogue(speaker: String, bengali: String, english: String, duration: float = 4.0) -> void:
    card.visible = true
    speaker_label.text = speaker
    bengali_label.text = bengali
    subtitle_label.text = english
    await get_tree().create_timer(duration).timeout
    card.visible = false
