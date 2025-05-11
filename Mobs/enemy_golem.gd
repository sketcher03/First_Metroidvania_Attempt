extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
# @onready var collision_shape_ground: CollisionShape2D = $CollisionShapeGround

@export var patrol_points: Node
@export var SPEED: int = 1500
@export var WAIT_TIME: int = 3
@export var health_amount: int = 10

const GRAVITY = 1000

enum State { Idle, Walk }

var current_state: State
var direction: Vector2 = Vector2.RIGHT
var number_of_points: int
var point_positions: Array[Vector2]
var current_point: Vector2
var current_point_position: int
var can_walk: bool
var is_hit: bool = false

func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No Patrol Points Found")
		
	timer.wait_time = WAIT_TIME
	
	current_state = State.Idle

func _physics_process(delta: float) -> void:
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	
	move_and_slide()
	
	enemy_animations()
	# print("Is Hit: " + str(is_hit))

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta
	
func enemy_idle(delta: float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		current_state = State.Idle
	
func enemy_walk(delta: float):
	if !can_walk:
		return
		
	# print("Position Difference: " + str(abs(position.x - current_point.x)))
	if not is_hit:
		if abs(position.x - current_point.x) > 0.5:
			velocity.x = direction.x * SPEED * delta
			current_state = State.Walk
		else:
			current_point_position += 1
		
			if current_point_position >= number_of_points:
				current_point_position = 0
			
			current_point = point_positions[current_point_position];
			
			if current_point.x > position.x:
				direction = Vector2.RIGHT
			else:
				direction = Vector2.LEFT
				
			can_walk = false
			timer.start()
		
	animated_sprite_2d.flip_h = direction.x < 0
	
func enemy_animations():
	if not is_hit:
		if current_state == State.Idle and !can_walk:
			animated_sprite_2d.play("idle")
		elif current_state == State.Walk and can_walk:
			animated_sprite_2d.play("walk")
		
#func enemy_damage(area: Area2D) -> void:
	#if get_parent().has_method("get_damage_amount"):
		#var node = area.get_parent() as Node
		#print("Attacking: " + str(node.is_attacking))
		#if node.is_attacking:
			#health_amount -= node.damage_amount
			# print("Health Amount: " + str(health_amount))

func _on_timer_timeout() -> void:
	can_walk = true

func _on_player_damage_dealt(damage_amount: int, player_direction: float) -> void:
	# var time_in_seconds = 0.5
	# await get_tree().create_timer(time_in_seconds).timeout
	
	is_hit = true
	health_amount -= damage_amount
	animated_sprite_2d.stop()
	animated_sprite_2d.play("hit")
	
	print("Health Amount: " + str(health_amount))
	
	if health_amount <= 0:
		# collision_shape_ground.queue_free()
		# await get_tree().create_timer(time_in_seconds * 2).timeout
		queue_free()
		
	if is_hit and not animated_sprite_2d.is_playing():
		is_hit = false
