extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Idle")
	can_transition = true

func transition():
	if can_transition and owner.can_attack:
		get_parent().change_state("Attack State")
	elif can_transition and owner.running:
		get_parent().change_state("Run State")
	elif can_transition and owner.dash:
		get_parent().change_state("Dash State")
	elif can_transition and owner.jump_starter:
		get_parent().change_state("Jump Start State")
	elif can_transition and owner.player_fell:
		get_parent().change_state("Fall State")
	elif owner.can_swim and not owner.can_water_jump:
		get_parent().change_state("Swim State")
