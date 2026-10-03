extends Control

const GAME_SCENE := "res://scenes/main.tscn"
const CJK_FONT: Font = preload("res://assets/ui/NotoSansSC-Regular.ttf")
const WEB_PLAYTEST_BRIDGE: Script = preload("res://scripts/web_playtest_bridge.gd")

@onready var title_label: Label = $TitleCard/TitleLabel
@onready var start_button: Button = $TitleCard/StartButton

func _ready() -> void:
	var pixel_font := title_label.get_theme_font("font")
	if pixel_font:
		pixel_font.fallbacks = [CJK_FONT]
	start_button.pressed.connect(_start_game)
	start_button.grab_focus()
	if WEB_PLAYTEST_BRIDGE.is_autoplay_requested():
		call_deferred("_start_game")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
