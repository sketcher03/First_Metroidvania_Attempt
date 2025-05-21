extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Crouch")
	can_transition = true

func transition():
	if owner.slide:
		get_parent().change_state("Slide State")
	elif can_transition:
		if owner.idle:
			get_parent().change_state("Idle State")
		elif owner.running:
			get_parent().change_state("Run State")
		elif owner.jump_starter:
			get_parent().change_state("Jump Start State")
		elif owner.can_attack:
			get_parent().change_state("Attack State")
