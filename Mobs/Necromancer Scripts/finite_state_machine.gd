extends Node2D

var current_state: State_1_0
var previous_state: State_1_0

# with _ready function, make sure the game starts from the first State in the list
func _ready() -> void:
	current_state = get_child(0) as State_1_0
	previous_state = current_state
	current_state.enter()

# Handle State transitions
func change_state(state):
	if state == previous_state.name:
		return
		
	current_state = find_child(state) as State_1_0
	current_state.enter()
	
	previous_state.exit()
	previous_state = current_state
	
# check the can_move variable
func check_if_can_move():
	return current_state.can_move
	
func check_can_air_jump():
	return current_state.can_air_jump
	
