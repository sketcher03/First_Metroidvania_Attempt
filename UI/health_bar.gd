extends TextureProgressBar

func _ready() -> void:
	Global.health_changed.connect(update)
	value = 100.0
	update()

func update():
	value = Global.current_player_health
