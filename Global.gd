extends Node

signal health_changed
signal coin_picked_up

var player_position: Vector2 = Vector2.ZERO
var current_player_health = 100.0
var after_death: bool = false
static var total_coin_amount: int
var key_count: int = 0

func update_key_count():
	key_count += 1

func reload_after_death():
	after_death = true
	get_tree().reload_current_scene()

func update_player_position(new_position: Vector2):
	player_position = new_position

func update_player_health(new_health, max_health):
	if after_death:
		after_death = false
	
	current_player_health = new_health * 100 / max_health
	health_changed.emit()

func update_player_coin(new_coin_amount: int):
	total_coin_amount += new_coin_amount
	coin_picked_up.emit(total_coin_amount)
