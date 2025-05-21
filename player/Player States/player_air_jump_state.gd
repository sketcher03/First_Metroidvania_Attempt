extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	owner.reset_air_jump()
	animation_player.play("Jump")
	await animation_player.animation_finished
	animation_player.play("Jump_Loop")
	can_transition = true

func transition():
	if can_transition:
		if owner.player_fell:
			get_parent().change_state("Fall State")
		elif owner.can_attack:
			get_parent().change_state("Attack State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
		elif owner.is_on_floor():
			get_parent().change_state("Jump End State")
		elif owner.is_edge_grabbing:
			get_parent().change_state("Edge Grab State")
		elif owner.can_wall_cling:
			get_parent().change_state("Wall Cling State")
		elif owner.can_swim and not owner.can_water_jump:
			get_parent().change_state("Swim State")
