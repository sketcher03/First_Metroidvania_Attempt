extends State_1_0

var can_transition = false

func enter():
	super.enter()
	
	can_transition = false
	animation_player.play("Wall_Cling")
	can_transition = true

func transition():
	if can_transition and owner.jump_starter:
		get_parent().change_state("Jump Start State")
