extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Run")
	can_transition = true

func transition():
	if can_transition:
		if owner.can_attack:
			get_parent().change_state("Attack State")
		elif owner.dash:
			get_parent().change_state("Dash State")
		elif owner.idle:
			get_parent().change_state("Idle State")
		elif owner.jump_starter:
			get_parent().change_state("Jump Start State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
		elif owner.player_fell:
			get_parent().change_state("Fall State")
		elif can_transition and owner.can_swim and not owner.can_water_jump:
			get_parent().change_state("Swim State")
