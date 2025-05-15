extends Node2D

@export var key_id: String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		InventoryManager.add_to_inventory("Key", key_id)
		queue_free()
