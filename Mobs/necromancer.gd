extends CharacterBody2D

# onready variables
@onready var player_detection: Area2D = $PlayerDetection
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var finite_state_machine: Node2D = $FiniteStateMachine
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_right: RayCast2D = $RayCasts/RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCasts/RayCastLeft
@onready var attack_area: Area2D = $AttackArea2D
@onready var progress_bar: ProgressBar = $ProgressBar

# variables
var mandatory_idle_active = false
var is_player_in_range = false
var is_close_to_player = false
var direction = Vector2.RIGHT
var is_dead = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# export variables
@export var change_direction: float  = 2.0
@export var stop_distance: float  = 10.0
@export var attack_range: float  = 50.0
@export var damage_dealt: int  = 40
@export var move_speed: int  = 28
@export var chase_speed: int  = 60
@export var health: int = 100
@export var knockback_force = Vector2(250, -15)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	progress_bar.value = health
	# variables to calculate the distance between player and the enemy. 
	# player's position comes from the Global.gd file set in Autoload
	var distance_to_player = global_position.distance_to(Global.player_position)
	var player_position = Global.player_position
	var direction_to_player_x = player_position.x - global_position.x
	
	# gravity affecting the y-axis
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# change direction when player enters the chase range
	if is_player_in_range:
		if abs(direction_to_player_x) > change_direction:
			direction.x = sign(direction_to_player_x)
			sprite_2d.flip_h = direction.x < 0
	
	# bounce off walls when not in chase range
	if is_player_in_range == false:
		check_wall_collision()
		
	# start attack when the player is in strike range
	if distance_to_player <= attack_range and mandatory_idle_active == false:
		start_attack_animation()
		
	# if player is within chase or attack range and the enemy cannot proceed due to raycasts -> Mandatory Idle State
	if is_player_in_range and ray_cast_right.is_colliding() and direction == Vector2.RIGHT:
		mandatory_transition()
	if is_player_in_range and ray_cast_left.is_colliding() and direction == Vector2.LEFT:
		mandatory_transition()
		
	# how fast the enemy moves under conditions
	if is_player_in_range and finite_state_machine.check_if_can_move():
		if abs(direction_to_player_x) > stop_distance:
			velocity.x = direction.x * chase_speed
		else:
			velocity.x = 0
	else:
		if finite_state_machine.check_if_can_move():
			velocity.x = direction.x * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
	
	# for changing the attack area based on the direction 
	update_attack_area_direction()
	move_and_slide()
	
func mandatory_transition():
	mandatory_idle_active = true
	
func update_attack_area_direction():
	if direction == Vector2.RIGHT:
		attack_area.scale.x = 1
	else:
		attack_area.scale.x = -1
		
func check_wall_collision():
	if ray_cast_right.is_colliding():
		direction = Vector2.LEFT
		sprite_2d.flip_h = true
	
	if ray_cast_left.is_colliding():
		direction = Vector2.RIGHT
		sprite_2d.flip_h = false

func start_attack_animation():
	is_close_to_player = true

# signal functions allowing variable changes
func _on_player_detected(body: Node2D) -> void:
	if body.is_in_group("players"):
		is_player_in_range = true

func _on_player_lost(body: Node2D) -> void:
	if body.is_in_group("players"):
		is_player_in_range = false

func _on_attack_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.take_damage(damage_dealt, global_position)

func _on_melee_area_entered(body: Node2D) -> void:
	# print("Player too close")
	if body.is_in_group("players"):
		body.take_damage(damage_dealt * 0.3, global_position)

# indicates when the player is out of attack range
func reset_attack_state():
	is_close_to_player = false

# enable the enemy to take damage, get knocked back and die
func take_damage(damage):
	if is_dead:
		return
	
	# take damage
	health -= damage
	print("Health: " + str(health))
	
	var player_position = Global.player_position
	var knockback_direction = (global_position - player_position).normalized()
	apply_knockback(Vector2(knockback_force.x * knockback_direction.x, knockback_force.y))
	
	if health <= 0:
		die()
	else:
		finite_state_machine.change_state("Hit State")

func apply_knockback(force: Vector2):
	velocity = force
	move_and_slide()
	
func die():
	is_dead = true
	finite_state_machine.change_state("Death State")
