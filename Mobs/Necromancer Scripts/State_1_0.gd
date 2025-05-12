extends Node2D

class_name State_1_0

@export var can_move: bool = true
@export var can_air_jump: bool = false

@onready var debug = owner.find_child("Debug")
@onready var player = owner.get_parent().find_child("Player")
@onready var animation_player = owner.find_child("AnimationPlayer")

func _ready() -> void:
	set_physics_process(false)
	
func enter():
	set_physics_process(true)
	
func exit():
	set_physics_process(false)
	
func transition():
	pass
	
func _physics_process(delta: float) -> void:
	transition()
	debug.text = name
