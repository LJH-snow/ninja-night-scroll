extends Control

const GAME_SCENE := "res://scenes/main.tscn"
const CJK_FONT: Font = preload("res://assets/ui/NotoSansSC-Regular.ttf")
const WEB_PLAYTEST_BRIDGE: Script = preload("res://scripts/web_playtest_bridge.gd")

@onready var title_label: Label = $TitleCard/TitleLabel
@onready var start_button: Button = $TitleCard/StartButton
@onready var language_button: Button = $TitleCard/LanguageButton
@onready var move_label: Label = $TitleCard/MoveLabel
@onready var attack_label: Label = $TitleCard/AttackLabel
@onready var objective_label: Label = $TitleCard/ObjectiveLabel

func _ready() -> void:
	var pixel_font := title_label.get_theme_font("font")
	if pixel_font:
		pixel_font.fallbacks = [CJK_FONT]
	LocalePreferences.apply_saved_locale()
	_translate_static_texts()
	start_button.pressed.connect(_start_game)
	start_button.grab_focus()
	language_button.pressed.connect(_on_language_toggle_pressed)
	_apply_dynamic_texts()
	if WEB_PLAYTEST_BRIDGE.is_autoplay_requested():
		call_deferred("_start_game")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()

func _on_language_toggle_pressed() -> void:
	var new_locale := LocalePreferences.next_locale(TranslationServer.get_locale())
	TranslationServer.set_locale(new_locale)
	LocalePreferences.save_locale(new_locale)
	language_button.text = LocalePreferences.toggle_label(new_locale)
	_apply_dynamic_texts()

func _apply_dynamic_texts() -> void:
	language_button.text = LocalePreferences.toggle_label(TranslationServer.get_locale())
	move_label.text = "%s\n%s" % [tr("WASD / 方向键"), tr("移动")]
	attack_label.text = "%s\n%s" % [tr("Space"), tr("攻击")]
	objective_label.text = "%s\n%s" % [tr("3 个卷轴"), tr("三分钟内到出口")]

func _translate_static_texts() -> void:
	$TitleCard/EyebrowLabel.text = tr("NINJA NIGHT RUN  ·  2D 动作逃脱")
	$TitleCard/TitleLabel.text = tr("忍者夜行：三分钟夺卷")
	$TitleCard/SubtitleLabel.text = tr("潜入敌营，收集三份卷轴，在倒计时结束前逃到出口。")
	$TitleCard/ShowcaseBand/PlayerName.text = tr("玩家忍者")
	$TitleCard/ShowcaseBand/EnemyName.text = tr("追踪敌人")
	$TitleCard/ControlsLabel.text = tr("操作说明")
	$TitleCard/StartButton.text = tr("开始游戏")
	$TitleCard/StartHint.text = tr("Enter  开始潜入")

func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
