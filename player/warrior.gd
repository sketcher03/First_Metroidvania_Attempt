extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine: Node2D = $StateMachine
@onready var raycast_jump_finish_right: RayCast2D = $RayCasts/raycast_jump_finish_right
@onready var raycast_jump_finish_left: RayCast2D = $RayCasts/raycast_jump_finish_left
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var attack_area: Area2D = $"Attack Area"
@onready var heal_effect_player: AnimationPlayer = $Heal_Effect_Player

@export var health = 100
@export var running_speed = 150
@export var swimming_speed = 75
@export var dash_speed = 300
@export var jump_power = -300
@export var double_jump_power = -300
@export var player_damage = 10
@export var knockback_force = Vector2(350, -25)

var direction: Vector2 = Vector2.ZERO
const MAX_HEALTH = 100

# State switching helper variables
var idle: bool = false
var running: bool = false
var dash: bool = false
var can_dash_attack: bool = false
var jump_starter: bool = false
var jump_finisher: bool = false
var player_fell: bool = false
var can_attack: bool = false
var can_combo_attack: bool = false
var can_air_jump: bool = false
var is_dead: bool = false
var can_swim: bool = false
var can_water_jump: bool = false
var current_jump_count: int = 0

func _physics_process(delta: float) -> void:
	progress_bar.value = health
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
	
	direction = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0)
	
	if direction.x != 0 and state_machine.check_if_can_move() and !can_swim:
		if dash:
			if not can_dash_attack:
				velocity.x = direction.x * dash_speed
			else:
				velocity.x = move_toward(velocity.x, 0, dash_speed)
		else:
			velocity.x = direction.x * running_speed
	elif can_swim:
		velocity.x = direction.x * swimming_speed
		velocity.y = velocity.y * 0.5
	else:
		if dash:
			var dash_direction = -1 if sprite_2d.flip_h else 1
			if not can_dash_attack:
				velocity.x = dash_direction * dash_speed
			else:
				velocity.x = move_toward(velocity.x, 0, dash_speed)
		else:
			velocity.x = move_toward(velocity.x, 0, running_speed)
	
	# print("Dash", dash)
	
	move_and_slide()
	player_position_check()
	state_switch()
	Global.update_player_position(global_position)

func player_position_check():
	if direction.x > 0:
		sprite_2d.flip_h = false
		attack_area.scale.x = 1
		sprite_2d.position.x = 5
	elif direction.x < 0:
		sprite_2d.flip_h = true
		attack_area.scale.x = -1
		sprite_2d.position.x = -5

func state_switch():
	if Input.is_action_just_pressed("jump") and state_machine.check_can_air_jump() and current_jump_count <= 2:
		can_air_jump = true
		velocity.y = double_jump_power
		current_jump_count += 1
	#elif Input.is_action_just_pressed("attack2") and can_attack:
		#can_combo_attack
	elif Input.is_action_just_pressed("attack") and !dash:
		can_attack = true
	elif Input.is_action_just_pressed("dash") and is_on_floor() and !can_swim:
		can_dash_attack = false
		dash = true
	elif Input.is_action_just_pressed("attack") and dash:
		can_dash_attack = true
	elif direction.x == 0 and is_on_floor() and !can_swim:
		current_jump_count = 0
		idle = true
		running = false
		jump_starter = false
		jump_finisher = false
		player_fell = false
	elif direction.x != 0 and is_on_floor() and !can_swim:
		current_jump_count = 0
		idle = false
		running = true
		jump_starter = false
		jump_finisher = false
		player_fell = false
	elif can_swim:
		if Input.is_action_pressed("jump"):
			if can_water_jump and current_jump_count <= 1:
				current_jump_count += 1
				can_swim = false
				velocity.y = jump_power
			else:
				position.y -= 0.75
		idle = false
		running = false
		jump_starter = false
		jump_starter = false
		jump_finisher = false
		player_fell = false
	elif Input.is_action_just_pressed("jump") and velocity.y <= 0:
		current_jump_count += 1
		idle = false
		running = false
		jump_starter = true
		jump_finisher = false
		player_fell = false
		can_swim = false
	elif (raycast_jump_finish_right.is_colliding() or raycast_jump_finish_left.is_colliding()) and velocity.y > 0 and not is_on_floor():
		# print("jump ended")
		if Input.is_action_just_pressed("jump") and current_jump_count == 0:
			can_air_jump = true
			velocity.y = double_jump_power
		idle = false
		running = false
		jump_starter = false
		jump_finisher = true
		player_fell = false
	elif velocity.y > 0:
		idle = false
		running = false
		jump_starter = false
		jump_finisher = false
		player_fell = true

func reset_air_jump():
	can_air_jump = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		#var damage_dealt = 30 if state_machine.
		body.take_damage(player_damage)

func heal(healing_amount):
	heal_effect_player.play("Heal_Timer")
	if health < 100:
		health += healing_amount
		
		if health >= MAX_HEALTH:
			health = MAX_HEALTH
		
		Global.update_player_health(health, MAX_HEALTH)
		print("Player Health: " + str(health))

func take_damage(enemy_damage, enemy_position):
	if is_dead:
		return
	
	health -= enemy_damage
	Global.update_player_health(health, MAX_HEALTH)
	print("Player Health: " + str(health))
	
	var knockback_direction = (global_position - enemy_position).normalized()
	apply_knockback(Vector2(knockback_force.x * knockback_direction.x, knockback_force.y))
	
	if health <= 0:
		die()
	else:
		state_machine.change_state("Hurt State")

func apply_knockback(force: Vector2):
	velocity = force
	move_and_slide()

func die():
	is_dead = true
	state_machine.change_state("Death State")

func _on_out_of_water_area_exited(area: Area2D) -> void:
	if area.is_in_group("waterbody"):
		can_water_jump = true
		if is_on_floor():
			can_swim = false
			idle = true

func _on_out_of_water_area_entered(area: Area2D) -> void:
	if area.is_in_group("waterbody"):
		can_water_jump = false
		can_swim = true
		idle = false
		running = false
		current_jump_count = 0
