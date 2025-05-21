extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Wall_Slide")
	can_transition = true

func transition():
	if can_transition:
		if owner.jump_starter:
			get_parent().change_state("Jump Start State")
		elif owner.is_on_floor():
			get_parent().change_state("Idle State")
		elif owner.can_wall_cling:
			get_parent().change_state("Wall Cling State")
