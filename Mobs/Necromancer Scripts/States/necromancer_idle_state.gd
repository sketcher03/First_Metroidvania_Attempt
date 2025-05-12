extends State_1_0

# State transitions managed using timer or condition broken in looping animations
@export var idle_timer = 1.5
var can_transition = false
var can_transition_chase = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Idle")
	await wait_for_idle()
	can_transition_chase = true

func wait_for_idle():
	await get_tree().create_timer(idle_timer).timeout
	can_transition = true

# for other animations, the state transition is triggered when the animation ends
func transition():
	if can_transition_chase and owner.is_player_in_range:
		get_parent().change_state("Chase State")
	elif can_transition:
		get_parent().change_state("Walk State")
