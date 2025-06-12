extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Wall_Cling")
	can_transition = true

func transition():
	if can_transition:
		if owner.jump_starter:
			get_parent().change_state("Jump Start State")
		elif owner.can_wall_slide:
			get_parent().change_state("Wall Slide State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
