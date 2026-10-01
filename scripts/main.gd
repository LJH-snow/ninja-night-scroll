extends Node2D

const SCROLL_TARGET := 3
const GAME_DURATION := 180.0
const CJK_FONT: Font = preload("res://assets/ui/NotoSansSC-Regular.ttf")

@onready var player: NinjaPlayer = $Playfield/Player
@onready var timer_label: Label = $HUD/StatusPanel/TimerLabel
@onready var health_label: Label = $HUD/StatusPanel/HealthLabel
@onready var scroll_label: Label = $HUD/StatusPanel/ScrollLabel
@onready var objective_label: Label = $Playfield/ObjectiveLabel
@onready var exit_zone: Area2D = $Playfield/ExitZone
@onready var result_overlay: ColorRect = $HUD/ResultOverlay
@onready var result_label: Label = $HUD/ResultOverlay/ResultLabel
@onready var restart_label: Label = $HUD/ResultOverlay/RestartLabel
@onready var music: AudioStreamPlayer = $Audio/Music
@onready var attack_sfx: AudioStreamPlayer = $Audio/AttackSfx
@onready var pickup_sfx: AudioStreamPlayer = $Audio/PickupSfx
@onready var hurt_sfx: AudioStreamPlayer = $Audio/HurtSfx
@onready var victory_sfx: AudioStreamPlayer = $Audio/VictorySfx
@onready var flash_overlay: ColorRect = $HUD/FlashOverlay

var scrolls_collected := 0
var remaining_time: float = GAME_DURATION
var game_over := false
var last_health := -1

func _ready() -> void:
	_configure_ui_font_fallback()
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	player.attack_started.connect(_on_attack_started)
	exit_zone.connect("player_entered", Callable(self, "_on_exit_entered"))
	music.finished.connect(_on_music_finished)
	for pickup_node in get_tree().get_nodes_in_group("scroll_pickups"):
		var pickup: Area2D = pickup_node as Area2D
		if pickup and pickup.has_signal("collected"):
			pickup.connect("collected", Callable(self, "_on_scroll_collected"))
	_on_player_health_changed(player.health, player.max_health)
	_update_scroll_hud()
	_update_timer_hud()
	_play_audio(music)

func _exit_tree() -> void:
	if is_instance_valid(music):
		music.stop()
		music.stream = null
	if is_instance_valid(attack_sfx):
		attack_sfx.stop()
	if is_instance_valid(pickup_sfx):
		pickup_sfx.stop()
	if is_instance_valid(hurt_sfx):
		hurt_sfx.stop()
	if is_instance_valid(victory_sfx):
		victory_sfx.stop()

func _configure_ui_font_fallback() -> void:
	var pixel_font := timer_label.get_theme_font("font")
	if pixel_font == null:
		return
	pixel_font.fallbacks = [CJK_FONT]

func _process(delta: float) -> void:
	if game_over:
		return
	remaining_time = maxf(remaining_time - delta, 0.0)
	_update_timer_hud()
	if remaining_time <= 0.0:
		_finish_game(false, "时间到")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and _is_restart_key(event) and game_over:
		get_tree().reload_current_scene()

func _on_player_health_changed(current_health: int, maximum_health: int) -> void:
	if last_health >= 0 and current_health < last_health:
		_play_audio(hurt_sfx)
		_flash_screen(Color(0.95, 0.2, 0.2, 1.0))
	last_health = current_health
	health_label.text = "生命 %d / %d" % [current_health, maximum_health]

func _on_attack_started() -> void:
	_play_audio(attack_sfx)

func _on_music_finished() -> void:
	if not game_over:
		_play_audio(music)

func _on_player_died() -> void:
	objective_label.text = "生命耗尽"
	_finish_game(false, "忍者倒下")

func _on_exit_entered() -> void:
	if game_over:
		return
	if scrolls_collected >= SCROLL_TARGET:
		_finish_game(true, "任务完成")
	else:
		objective_label.text = "还需收集 %d 个卷轴" % (SCROLL_TARGET - scrolls_collected)

func _on_scroll_collected() -> void:
	scrolls_collected = min(scrolls_collected + 1, SCROLL_TARGET)
	_play_audio(pickup_sfx)
	_flash_screen(Color(0.95, 0.76, 0.3, 1.0))
	_update_scroll_hud()

func _update_scroll_hud() -> void:
	scroll_label.text = "卷轴 %d / %d" % [scrolls_collected, SCROLL_TARGET]
	if scrolls_collected >= SCROLL_TARGET:
		objective_label.text = "出口已解锁"
	else:
		objective_label.text = "还需收集 %d 个卷轴" % (SCROLL_TARGET - scrolls_collected)

func _update_timer_hud() -> void:
	var total_seconds := maxi(int(ceil(remaining_time)), 0)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "时间 %02d:%02d" % [minutes, seconds]

func _finish_game(won: bool, message: String) -> void:
	if game_over:
		return
	game_over = true
	music.stop()
	result_overlay.visible = true
	result_label.text = message
	restart_label.text = "按 R 重新开始"
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	get_tree().call_group("enemies", "set_physics_process", false)
	if won:
		_play_audio(victory_sfx)
		_flash_screen(Color(0.95, 0.76, 0.3, 1.0))
	else:
		_play_audio(hurt_sfx)
		_flash_screen(Color(0.95, 0.2, 0.2, 1.0))

func _is_restart_key(event: InputEventKey) -> bool:
	return event.keycode == KEY_R or event.physical_keycode == KEY_R

func _flash_screen(color: Color) -> void:
	flash_overlay.color = color
	flash_overlay.modulate = Color(1.0, 1.0, 1.0, 0.38)
	create_tween().tween_property(flash_overlay, "modulate:a", 0.0, 0.18)

func _play_audio(audio_player: AudioStreamPlayer) -> void:
	if DisplayServer.get_name() != "headless":
		audio_player.play()
