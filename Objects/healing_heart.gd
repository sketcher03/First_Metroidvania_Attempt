extends Area2D

@export var heal_amount: float = 30.0

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.heal(heal_amount)
		queue_free()
