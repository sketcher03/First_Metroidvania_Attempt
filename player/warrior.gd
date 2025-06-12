extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine: Node2D = $StateMachine
@onready var raycast_jump_finish_right: RayCast2D = $RayCasts/raycast_jump_finish_right
@onready var raycast_jump_finish_left: RayCast2D = $RayCasts/raycast_jump_finish_left
@onready var raycast_ceiling_check: RayCast2D = $RayCasts/raycast_ceiling_check
@onready var raycast_ladder_check: RayCast2D = $RayCasts/raycast_ladder_check
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var attack_area: Area2D = $"Attack Area"
@onready var heal_effect_player: AnimationPlayer = $Heal_Effect_Player
@onready var raycast_grab_hand: RayCast2D = $RayCasts/raycast_grab_hand
@onready var raycast_grab_check: RayCast2D = $RayCasts/raycast_grab_check
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var health = 100
@export var running_speed = 150
@export var swimming_speed = 75
@export var crouch_speed = 60
@export var dash_speed = 300
@export var slide_speed = 200
@export var jump_power = -300
@export var double_jump_power = -300
@export var player_damage = 10
@export var dash_attack_damage = 30
@export var knockback_force = Vector2(350, -25)

var direction: Vector2 = Vector2.ZERO
const MAX_HEALTH = 100
const AFTER_DEATH_HEALTH = 60

# State switching helper variables
var idle: bool = false
var running: bool = false
var dash: bool = false
var slide: bool = false
var crouch: bool = false
var can_dash_attack: bool = false
var jump_starter: bool = false
var jump_finisher: bool = false
var player_fell: bool = false
var can_attack: bool = false
var can_combo_attack: bool = false
var can_air_jump: bool = false
var is_dead: bool = false
var can_swim: bool = false
var can_water_jump: bool = true
var is_edge_grabbing: bool = false
var is_climbing: bool = false
var is_climbing_stopped: bool = false
var is_climbing_up: bool = false
var is_climbing_down: bool = false
var can_wall_cling: bool = false
var can_wall_slide: bool = false
var current_jump_count: int = 0

func _physics_process(delta: float) -> void:
	progress_bar.value = health
	
	check_edge_grab()
	check_wall_cling()
	check_wall_slide()
	
	print("Direction.X: ", direction.x)
	
	if Global.after_death:
		Global.update_player_coin(0)
		Global.update_player_health(AFTER_DEATH_HEALTH, MAX_HEALTH)
	
	if not is_on_floor() and not is_climbing:
		if is_edge_grabbing or can_wall_cling:
			velocity = Vector2.ZERO
		elif can_wall_slide:
			velocity.y = 100.0
		else:
			velocity += get_gravity() * delta
	elif is_climbing:
		if direction.y != 0:
			velocity.x = 0
			velocity.y = direction.y * swimming_speed
		else:
			velocity = Vector2.ZERO

	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_edge_grabbing or can_wall_cling or can_wall_slide or is_climbing):
		is_edge_grabbing = false
		can_wall_cling = false
		can_wall_slide = false
		is_climbing = false
		velocity.y = jump_power
	
	#if is_edge_grabbing or can_wall_cling:
		#var can_fall = raycast_jump_finish_left.is_colliding() or raycast_jump_finish_right.is_colliding()
		#
		#if can_fall:
			# print("fall activated")
			#is_edge_grabbing = false
			#can_wall_cling = false
			#if can_wall_slide:
				#can_wall_slide = false
			#player_fell = true
	
	direction = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0)
	direction.y = Input.get_action_strength("wall_slide") - Input.get_action_strength("wall_cling") if is_climbing else 0.0
	
	if not can_wall_slide and not can_wall_cling and not is_edge_grabbing and not is_climbing:
		if direction.x != 0 and state_machine.check_if_can_move() and not can_swim:
			if dash:
				if not can_dash_attack:
					velocity.x = direction.x * dash_speed
				else:
					velocity.x = move_toward(velocity.x, 0, dash_speed)
			elif slide:
				velocity.x = direction.x * slide_speed
			elif crouch and raycast_ceiling_check.is_colliding():
				velocity.x = direction.x * crouch_speed
			else:
				velocity.x = direction.x * running_speed
		elif can_swim and not can_water_jump:
			velocity.x = direction.x * swimming_speed
			velocity.y = velocity.y * 0.5
		else:
			var dash_direction = -1 if sprite_2d.flip_h else 1
			if dash:
				if not can_dash_attack:
					velocity.x = dash_direction * dash_speed
				else:
					velocity.x = move_toward(velocity.x, 0, dash_speed)
			elif slide:
				velocity.x = dash_direction * slide_speed
			else:
				velocity.x = move_toward(velocity.x, 0, running_speed)
	
	# print("Edge Grab: ", is_edge_grabbing)
	
	if not is_edge_grabbing and not can_wall_cling:
		move_and_slide()
	if not can_wall_slide and not is_edge_grabbing and not can_wall_cling:
		player_position_check()
	state_switch()
	Global.update_player_position(global_position)

func player_position_check():
	if is_climbing and not is_on_floor():
		sprite_2d.position.x = 0
	else:
		if direction.x > 0:
			sprite_2d.flip_h = false
			attack_area.scale.x = 1
			sprite_2d.position.x = 5
			raycast_grab_check.target_position.x = 15
			raycast_grab_hand.target_position.x = 15
		elif direction.x < 0:
			sprite_2d.flip_h = true
			attack_area.scale.x = -1
			sprite_2d.position.x = -5
			raycast_grab_check.target_position.x = -15
			raycast_grab_hand.target_position.x = -15
		else:
			if sprite_2d.flip_h:
				sprite_2d.position.x = -5
			else:
				sprite_2d.position.x = 5

func state_switch():
	var ladderCollider = raycast_ladder_check.get_collider()
	
	if velocity.y > 0 and not raycast_jump_finish_right.is_colliding() and not raycast_jump_finish_left.is_colliding() and not can_swim:
		idle = false
		running = false
		jump_starter = false
		jump_finisher = false
		can_air_jump = false
		player_fell = true
	elif Input.is_action_just_pressed("jump") and state_machine.check_can_air_jump() and current_jump_count <= 2:
		can_air_jump = true
		velocity.y = double_jump_power
		current_jump_count += 1
	#elif Input.is_action_just_pressed("attack2") and can_attack:
		#can_combo_attack
	elif Input.is_action_just_pressed("attack") and !dash:
		can_attack = true
		crouch = false
	elif ladderCollider and (Input.is_action_pressed("wall_cling") or Input.is_action_pressed("wall_slide")) and not running and not is_climbing and not jump_starter and not jump_finisher and not can_air_jump and not player_fell:
		slide = false
		idle = false
		running = false
		crouch = false
		jump_starter = false
		jump_finisher = false
		player_fell = false
		is_climbing = true
	elif ladderCollider and is_climbing:
		if direction.y > 0 and not is_on_floor():
			is_climbing_down = true
			is_climbing_stopped = false
			is_climbing_up = false
		elif direction.y < 0:
			is_climbing_down = false
			is_climbing_stopped = false
			is_climbing_up = true
		elif is_on_floor():
			idle = true
			is_climbing = false
		else:
			is_climbing_down = false
			is_climbing_stopped = true
			is_climbing_up = false
	elif Input.is_action_just_pressed("dash") and !can_swim:
		can_dash_attack = false
		dash = true
	elif Input.is_action_just_pressed("wall_slide") and is_on_floor():
		slide = true
		if not raycast_ceiling_check.is_colliding() or crouch:
			crouch = false
	elif Input.is_action_just_pressed("attack") and dash:
		can_dash_attack = true
	elif Input.is_action_just_pressed("crouch") and (idle or crouch):
		if not crouch:
			idle = false
			crouch = true
		else:
			idle = true
			crouch = false
	elif raycast_ceiling_check.is_colliding() and velocity.y >= 0:
		if slide:
			crouch = false
		elif not (jump_finisher or jump_starter or player_fell):
			crouch = true
			idle = false
			running = false
	elif direction.x == 0 and is_on_floor() and !can_swim and not crouch:
		current_jump_count = 0
		idle = true
		crouch = false
		running = false
		is_climbing = false
		is_climbing_up = false
		is_climbing_down = false
		is_climbing_stopped = false
		jump_starter = false
		jump_finisher = false
		player_fell = false
		can_wall_slide = false
	elif direction.x != 0 and is_on_floor() and !can_swim:
		current_jump_count = 0
		idle = false
		running = true
		crouch = false
		is_climbing = false
		is_climbing_up = false
		is_climbing_down = false
		is_climbing_stopped = false
		jump_starter = false
		jump_finisher = false
		player_fell = false
		can_wall_slide = false
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
		crouch = false
		is_climbing = false
		is_climbing_up = false
		is_climbing_down = false
		is_climbing_stopped = false
		jump_starter = false
		jump_finisher = false
		player_fell = false
	elif Input.is_action_just_pressed("jump") and velocity.y <= 0:
		current_jump_count += 1
		idle = false
		running = false
		crouch = false
		is_climbing = false
		is_climbing_up = false
		is_climbing_down = false
		is_climbing_stopped = false
		jump_starter = true
		jump_finisher = false
		player_fell = false
		can_swim = false
	elif (raycast_jump_finish_right.is_colliding() or raycast_jump_finish_left.is_colliding()) and velocity.y > 0 and not is_on_floor():
		if Input.is_action_just_pressed("jump") and current_jump_count == 0:
			can_air_jump = true
			velocity.y = double_jump_power
		idle = false
		running = false
		jump_starter = false
		jump_finisher = true
		player_fell = false
		is_climbing = false
		is_climbing_up = false
		is_climbing_down = false
		is_climbing_stopped = false
		# can_wall_cling = false
	elif velocity.y > 0:
		idle = false
		running = false
		jump_starter = false
		jump_finisher = false
		player_fell = true
		is_climbing = false
		is_climbing_up = false
		is_climbing_down = false
		is_climbing_stopped = false

func reset_air_jump():
	can_air_jump = false

func check_edge_grab():
	if can_swim:
		return
	
	# print("Player Sprite Position x: ", sprite_2d.position.x)
	var check_hand = not raycast_grab_hand.is_colliding()
	var check_grab_height = raycast_grab_check.is_colliding()
	
	if is_edge_grabbing:
		if sprite_2d.flip_h:
			sprite_2d.position.x = -8
		else:
			sprite_2d.position.x = 12
	
	if velocity.y >= 0 and check_hand and check_grab_height and not is_edge_grabbing and is_on_wall_only() and not can_swim and not is_on_floor():
		is_edge_grabbing = true

func check_wall_slide():
	if can_swim:
		return
		
	if can_wall_cling:
		if Input.is_action_pressed("wall_slide") and is_on_wall_only() and not is_on_floor():
			can_wall_cling = false
			can_wall_slide = true

func check_wall_cling():
	if can_swim:
		return
		
	var check_hand = raycast_grab_hand.is_colliding()
	var check_grab_height = raycast_grab_check.is_colliding()
	
	if can_wall_cling or can_wall_slide:
		if sprite_2d.flip_h:
			sprite_2d.flip_h = true
			sprite_2d.position.x = -11
		else:
			sprite_2d.flip_h = false
			sprite_2d.position.x = 11
	
	# print("1: ", velocity.y >= 0, " 2: ", check_grab_height, " 3: ", check_hand, " 4: ", is_on_wall_only(), " 5: ", Input.is_action_pressed("wall_cling"), " 6: ", !can_wall_cling)
	if velocity.y >= 0 and check_grab_height and check_hand and is_on_wall_only() and Input.is_action_pressed("wall_cling") and not can_wall_cling and not jump_finisher:
		can_wall_slide = false
		can_wall_cling = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		var damage_dealt = dash_attack_damage if can_dash_attack else player_damage
		body.take_damage(damage_dealt)

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
