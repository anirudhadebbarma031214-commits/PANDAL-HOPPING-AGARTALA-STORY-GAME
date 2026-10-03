extends Node2D

var player := Vector2(640, 420)
var speed := 260.0

func _process(delta):
    var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    player += direction * speed * delta
    player.x = clamp(player.x, 60.0, 1220.0)
    player.y = clamp(player.y, 150.0, 650.0)
    queue_redraw()

func _draw():
    draw_rect(Rect2(0, 0, 1280, 720), Color("#070910"))
    draw_rect(Rect2(0, 330, 1280, 180), Color("#171b27"))
    for x in range(0, 1280, 100):
        draw_line(Vector2(x, 420), Vector2(x + 55, 420), Color("#dfe6f5"), 4)
    for i in range(10):
        var x = 30 + i * 128
        var height = 100 + (i % 4) * 35
        draw_rect(Rect2(x, 330 - height, 95, height), Color("#101625"))
    draw_circle(player, 22, Color("#7d5cff"))
    draw_circle(player, 12, Color("#090b14"))
    draw_rect(Rect2(28, 24, 470, 76), Color(0.04, 0.05, 0.09, 0.94))
    draw_string(ThemeDB.fallback_font, Vector2(50, 58), "PANDAL HOPPING", HORIZONTAL_ALIGNMENT_LEFT, 400, 28, Color("#ffffff"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 82), "AN AGARTALA STORY • A GAME BY ANI STUDIO", HORIZONTAL_ALIGNMENT_LEFT, 430, 14, Color("#91a9ff"))
    draw_rect(Rect2(28, 125, 405, 115), Color(0.04, 0.05, 0.09, 0.94))
    draw_string(ThemeDB.fallback_font, Vector2(50, 155), "CURRENT MISSION", HORIZONTAL_ALIGNMENT_LEFT, 330, 14, Color("#91a9ff"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 190), "Explore Badharghat", HORIZONTAL_ALIGNMENT_LEFT, 350, 24, Color("#ffffff"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 218), "Walk around • meet people • remember home", HORIZONTAL_ALIGNMENT_LEFT, 370, 14, Color("#b9c1d5"))
    draw_rect(Rect2(1000, 24, 252, 58), Color(0.04, 0.05, 0.09, 0.94))
    draw_string(ThemeDB.fallback_font, Vector2(1020, 50), "BADHARGHAT", HORIZONTAL_ALIGNMENT_LEFT, 220, 16, Color("#ffffff"))
    draw_string(ThemeDB.fallback_font, Vector2(1020, 71), "AGARTALA • 18:42", HORIZONTAL_ALIGNMENT_LEFT, 220, 13, Color("#91a9ff"))
