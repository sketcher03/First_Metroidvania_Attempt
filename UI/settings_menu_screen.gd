extends CanvasLayer

@onready var window_mode_option_button: OptionButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/WindowModeOptionButton

var window_modes: Dictionary = {
	"Fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"Windowed Maximized": DisplayServer.WINDOW_MODE_MAXIMIZED
	}

func _ready() -> void:
	for window_mode in window_modes:
		window_mode_option_button.add_item(window_mode)
	
	initialize_controls()

func initialize_controls():
	SettingsManager.load_settings()
	var settings_data: SettingsDataResource = SettingsManager.get_settings()
	window_mode_option_button.selected = settings_data.window_mode_index

func _on_window_mode_item_selected(index: int) -> void:
	var window_mode = window_modes.get(window_mode_option_button.get_item_text(index)) as int
	SettingsManager.set_window_mode(window_mode, index)

func _on_main_menu_button_pressed() -> void:
	SettingsManager.save_settings()
	queue_free()
