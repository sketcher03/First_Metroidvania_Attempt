extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Fall")
	can_transition = true

func transition():
	if can_transition:
		if owner.can_attack:
			get_parent().change_state("Attack State")
		elif owner.can_air_jump:
			get_parent().change_state("Air Jump State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
		elif owner.is_on_floor():
			get_parent().change_state("Jump End State")
		elif owner.can_swim:
			get_parent().change_state("Swim State")
		elif owner.is_edge_grabbing:
			get_parent().change_state("Edge Grab State")
		elif owner.can_wall_cling:
			get_parent().change_state("Wall Cling State")
