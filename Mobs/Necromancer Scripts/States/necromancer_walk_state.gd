extends State_1_0

# State transitions managed using timer or condition broken in looping animations
@export var walk_timer = 7.5
var can_transition = false
var can_transition_chase = false

func enter():
	super.enter()
	
	can_transition = false
	can_transition_chase = false
	animation_player.play("Walk")
	wait_for_walk()
	can_transition_chase = true
	
func wait_for_walk():
	await get_tree().create_timer(walk_timer).timeout
	can_transition = true

# for other animations, the state transition is triggered whedn the animation ends
func transition():
	# print("Can Chase: " + str(can_transition_chase) + ", In Range: " + str(owner.is_player_in_range))
	if can_transition_chase and owner.is_player_in_range:
		get_parent().change_state("Chase State")
	elif can_transition:
		get_parent().change_state("Idle State")
