extends Node2D

@export var key_id: String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		var key_name = "Key" + str(Global.key_count + 1)
		InventoryManager.add_to_inventory(key_name, key_id)
		Global.update_key_count()
		queue_free()
