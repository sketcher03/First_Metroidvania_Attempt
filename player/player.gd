extends CharacterBody2D

signal damage_dealt

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

const GRAVITY = 1000
@export var SPEED: int = 500
@export var MAX_HORIZONTAL_SPEED: int = 150
@export var SLOW_DOWN_SPEED: int = 6000

@export var JUMP_SPEED_VERTICAL: int = -300
@export var JUMP_SPEED_HORIZONTAL: int = 500
@export var MAX_JUMP_SPEED_HORIZONTAL: int = 150

enum State { Idle, Run, Jump, Attack }

var current_state: State
var is_attacking = false
var attack_cooldown = 0.0
const ATTACK_RATE = 0.4
var damage_amount: int = 1

# Hitbox
var entry: bool = false
var exit: bool = false

func _ready():
	current_state = State.Idle
	
func _process(delta: float) -> void:
	var direction = input_movement()
	
	if entry == true and exit == false:
		# print("Overlapping")
		if is_attacking and current_state == State.Attack:
			# print("State: " + State.keys()[current_state] + ", Damage: -" + str(damage_amount))
			damage_dealt.emit(damage_amount, direction)

func _physics_process(delta: float) -> void:
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_attacking(delta)
	
	move_and_slide()
	
	player_animations()
	# print("State: " + State.keys()[current_state] + ", Attacking: " + str(is_attacking))

func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta: float):
	if is_on_floor():
		current_state = State.Idle

func player_run(delta: float):
	if !is_on_floor() or is_attacking:
		return
	
	var direction = input_movement()
	
	if direction:
		velocity.x += direction * SPEED * delta
		velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SLOW_DOWN_SPEED * delta)
		
	if direction != 0:
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true
		animated_sprite_2d.position.x = 5 if direction > 0 else -5
		hitbox.scale.x = abs(hitbox.scale.x) * direction

func player_jump(delta: float):
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED_VERTICAL
		current_state = State.Jump
	
	if !is_on_floor() and current_state == State.Jump:
		var direction = input_movement()
		velocity.x += direction * JUMP_SPEED_HORIZONTAL * delta
		velocity.x = clamp(velocity.x, -MAX_JUMP_SPEED_HORIZONTAL, MAX_JUMP_SPEED_HORIZONTAL)
		if direction != 0:
			animated_sprite_2d.flip_h = false if direction > 0 else true
			animated_sprite_2d.position.x = 5 if direction > 0 else -5

func player_attacking(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if is_attacking and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SLOW_DOWN_SPEED * delta)
	
	var direction = input_movement()
	
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		is_attacking = true
		current_state = State.Attack
		attack_cooldown = ATTACK_RATE
		animated_sprite_2d.stop()
		animated_sprite_2d.play("attack")
		
	if is_attacking and not animated_sprite_2d.is_playing():
		is_attacking = false

func player_animations():
	if not is_attacking:
		if current_state == State.Idle:
			animated_sprite_2d.play("idle")
		elif current_state == State.Run:
			animated_sprite_2d.play("run")
		elif current_state == State.Jump:
			animated_sprite_2d.play("jump")

func input_movement():
	var direction: float = Input.get_axis("move_left", "move_right")
	
	return direction
	
func get_damage_amount() -> int:
	return damage_amount

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		entry = true
		exit = false

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.name == "Hurtbox":
		exit = true
		entry = false
