extends Node

signal health_changed
signal coin_picked_up

var player_position: Vector2 = Vector2.ZERO
var current_player_health = 100.0
static var total_coin_amount: int

func update_player_position(new_position: Vector2):
	player_position = new_position

func update_player_health(new_health, max_health):
	current_player_health = new_health * 100 / max_health
	health_changed.emit()

func update_player_coin(new_coin_amount: int):
	total_coin_amount += new_coin_amount
	coin_picked_up.emit(total_coin_amount)
