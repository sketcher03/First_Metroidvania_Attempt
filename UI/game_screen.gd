extends CanvasLayer

@onready var coin_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Control/Coin_Label

func _ready() -> void:
	Global.coin_picked_up.connect(update_coin)

func update_coin(total_coin_amount: int):
	coin_label.text = str(total_coin_amount)

func _on_pause_button_pressed() -> void:
	GameManager.pause_game()
