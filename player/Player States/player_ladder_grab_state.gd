extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Ladder_Grab")
	can_transition = true

func transition():
	if can_transition:
		if owner.idle:
			get_parent().change_state("Idle State")
		elif owner.is_climbing_up:
			get_parent().change_state("Ladder Climb Up State")
		elif owner.is_climbing_down:
			get_parent().change_state("Ladder Climb Down State")
		elif owner.jump_starter:
			get_parent().change_state("Jump Start State")
