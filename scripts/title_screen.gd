extends Control

const GAME_SCENE := "res://scenes/main.tscn"
const CJK_FONT: Font = preload("res://assets/ui/NotoSansSC-Regular.ttf")

@onready var title_label: Label = $TitleCard/TitleLabel
@onready var start_button: Button = $TitleCard/StartButton

func _ready() -> void:
	var pixel_font := title_label.get_theme_font("font")
	if pixel_font:
		pixel_font.fallbacks = [CJK_FONT]
	start_button.pressed.connect(_start_game)
	start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
