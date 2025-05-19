extends Area2D

var is_in_water_body: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		await get_tree().create_timer(0.1).timeout
		body.can_swim = true
		# await get_tree().create_timer(3.0).timeout
		# get_tree().reload_current_scene()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.can_swim = false
