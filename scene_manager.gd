extends Node

const LOADING_SCREEN = preload("res://UI/loading_screen.tscn")

var scenes: Dictionary = {
	"Level 1": "res://levels/level_1.tscn",
	"Level 2": "res://levels/level_2.tscn",
	"Test Level": "res://levels/test_levels/test_level.tscn",
}

func transition_to_scene(level: String):
	var scene_path: String = scenes.get(level)
	
	if scene_path != null:
		var loading_screen_instance = LOADING_SCREEN.instantiate()
		get_tree().get_root().add_child(loading_screen_instance)
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file(scene_path)
		loading_screen_instance.queue_free()
