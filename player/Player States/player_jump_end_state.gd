extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Fall")
	#await animation_player.animation_finished
	can_transition = true

func transition():
	if can_transition:
		if owner.idle:
			get_parent().change_state("Idle State")
		elif owner.player_fell:
			get_parent().change_state("Fall State")
		elif owner.running:
			get_parent().change_state("Run State")
		elif owner.can_swim:
			get_parent().change_state("Swim State")
