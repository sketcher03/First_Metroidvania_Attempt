extends Area2D

@export var award_amount: int = 1
@onready var coin: Area2D = $"."

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		# print("Coin picked up!")
		
		Global.update_player_coin(award_amount)
		
		var tween = get_tree().create_tween()
		tween.tween_property(coin, "position", Vector2(coin.position.x, coin.position.y + -20), 0.4).from_current()
		tween.tween_callback(queue_free)
