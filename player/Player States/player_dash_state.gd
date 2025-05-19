extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Dash")
	await animation_player.animation_finished
	owner.dash = false
	can_transition = true

func transition():
	if owner.can_dash_attack:
			get_parent().change_state("Dash Attack State")
	if can_transition:
		if owner.player_fell:
			get_parent().change_state("Fall State")
		elif owner.idle:
			get_parent().change_state("Idle State")
		elif owner.running:
			get_parent().change_state("Run State")
		elif owner.jump_starter:
			get_parent().change_state("Jump Start State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
		elif owner.is_edge_grabbing:
			get_parent().change_state("Edge Grab State")
		elif owner.can_wall_cling:
			get_parent().change_state("Wall Cling State")
