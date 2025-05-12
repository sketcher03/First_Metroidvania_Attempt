extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Hurt")
	await animation_player.animation_finished
	can_transition = true

func transition():
	if can_transition:
		if owner.running:
			get_parent().change_state("Run State")
		elif owner.idle:
			get_parent().change_state("Idle State")
		elif owner.player_fell:
			get_parent().change_state("Fall State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
		elif owner.can_air_jump:
				get_parent().change_state("Air Jump State")
