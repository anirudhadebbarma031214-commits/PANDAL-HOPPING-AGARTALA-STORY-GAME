extends Node

# Independent safety net: if procedural startup gets stuck, reveal the
# static fallback world instead of leaving the player behind a loading layer.
func _ready() -> void:
    await get_tree().create_timer(8.0).timeout
    var loading_layer := get_parent().get_node_or_null("BootLoadingLayer")
    if loading_layer != null and is_instance_valid(loading_layer):
        loading_layer.queue_free()
