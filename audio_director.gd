extends Node
## Procedural audio fallback: no external audio assets required.
## Creates gentle ambience tones; replace with licensed recordings when available.

var ambience_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    ambience_player = AudioStreamPlayer.new()
    ambience_player.name = "CityAmbience"
    add_child(ambience_player)
    music_player = AudioStreamPlayer.new()
    music_player.name = "StoryMusic"
    add_child(music_player)

func play_city_ambience() -> void:
    # Placeholder hook kept silent until recorded ambience is supplied.
    # This avoids synthetic harsh tones or unsupported audio resources.
    if ambience_player:
        ambience_player.stop()

func play_story_cue(_cue_name: String) -> void:
    # Hook for future licensed dhak, traffic and emotional score assets.
    if music_player:
        music_player.stop()
