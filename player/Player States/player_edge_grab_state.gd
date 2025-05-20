extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Edge_Grab")
	await animation_player.animation_finished
	animation_player.play("Edge_Idle")
	can_transition = true

func transition():
	if can_transition and owner.jump_starter:
		get_parent().change_state("Jump Start State")
	elif can_transition and owner.is_on_floor():
		if owner.running:
			get_parent().change_state("Run State")
		elif owner.idle:
			get_parent().change_state("Idle State")
		elif owner.dash:
			get_parent().change_state("Dash State")
