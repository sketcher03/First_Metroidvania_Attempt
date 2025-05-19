extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Jump_Loop")
	can_transition = true

func transition():
	if can_transition:
		if owner.jump_starter:
			get_parent().change_state("Jump Start State")
		elif owner.jump_finisher:
			get_parent().change_state("Jump End State")
		elif owner.idle:
			get_parent().change_state("Idle State")
		elif owner.running:
			get_parent().change_state("Run State")
