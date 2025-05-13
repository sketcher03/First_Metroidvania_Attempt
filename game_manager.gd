extends Node

const LEVEL_1 = preload("res://levels/level_1.tscn")
const PAUSE_MENU_SCREEN = preload("res://UI/pause_menu_screen.tscn")
const MAIN_MENU_SCREEN = preload("res://UI/main_menu_screen.tscn")

func start_game():
	if get_tree().paused:
		continue_game()
		return
	
	transition_to_scene(LEVEL_1.resource_path)

func exit_game():
	get_tree().quit()

func pause_game():
	get_tree().paused = true
	var pause_menu_screen_instance = PAUSE_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(pause_menu_screen_instance)

func continue_game():
	get_tree().paused = false

func main_menu():
	var main_menu_screen_instance = MAIN_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(main_menu_screen_instance)

func transition_to_scene(scene_path):
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)
