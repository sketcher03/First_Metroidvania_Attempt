extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var next_scene: String
@export var key_id: String

var door_open: bool

func _on_exit_area_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		var player = body as CharacterBody2D
		player.queue_free()
	
	await  get_tree().create_timer(1.5).timeout
	SceneManager.transition_to_scene(next_scene)


func _on_activate_door_area_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		var has_item: bool = InventoryManager.has_inventory_item(key_id)
		
		if not has_item:
			return
		
		if !door_open:
			door_open = true
			collision_shape_2d.set_deferred("disabled", true)


func _on_activate_door_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		if door_open:
			door_open = false
			
