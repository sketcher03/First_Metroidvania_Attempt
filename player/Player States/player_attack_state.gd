extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Attack")
	await animation_player.animation_finished
	owner.can_attack = false
	can_transition = true

func transition():
	if can_transition:
		#if owner.can_combo_attack:
			#get_parent().change_state("Attack2 State")
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
		
