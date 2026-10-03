extends Node2D

const SCROLL_TARGET := 3
const GAME_DURATION := 180.0
const SETTINGS_PATH := "user://settings.cfg"
const SCREEN_SHAKE_DECAY := 7.0
const SCREEN_SHAKE_PIXELS := 9.0
const VOLUME_SAVE_DELAY := 0.4
const CJK_FONT: Font = preload("res://assets/ui/NotoSansSC-Regular.ttf")
const WEB_PLAYTEST_BRIDGE: Script = preload("res://scripts/web_playtest_bridge.gd")

@onready var player: NinjaPlayer = $Player
@onready var timer_label: Label = $HUD/StatusPanel/TimerLabel
@onready var health_label: Label = $HUD/StatusPanel/HealthLabel
@onready var scroll_label: Label = $HUD/StatusPanel/ScrollLabel
@onready var boss_panel: Panel = $HUD/BossPanel
@onready var boss_name_label: Label = $HUD/BossPanel/BossNameLabel
@onready var boss_health_bar: ProgressBar = $HUD/BossPanel/BossHealthBar
@onready var playfield: Panel = $Playfield
@onready var level_two: Panel = $LevelTwo
@onready var level_three: Panel = $LevelThree
@onready var level_four: Panel = $LevelFour
@onready var level_five: Panel = $LevelFive
@onready var subtitle_label: Label = $Subtitle
@onready var objective_label: Label = $Playfield/ObjectiveLabel
@onready var result_overlay: ColorRect = $HUD/ResultOverlay
@onready var result_label: Label = $HUD/ResultOverlay/ResultLabel
@onready var restart_label: Label = $HUD/ResultOverlay/RestartLabel
@onready var music: AudioStreamPlayer = $Audio/Music
@onready var attack_sfx: AudioStreamPlayer = $Audio/AttackSfx
@onready var pickup_sfx: AudioStreamPlayer = $Audio/PickupSfx
@onready var hurt_sfx: AudioStreamPlayer = $Audio/HurtSfx
@onready var victory_sfx: AudioStreamPlayer = $Audio/VictorySfx
@onready var flash_overlay: ColorRect = $HUD/FlashOverlay
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var resume_button: Button = $HUD/PauseOverlay/PausePanel/ResumeButton
@onready var restart_button: Button = $HUD/PauseOverlay/PausePanel/RestartButton
@onready var title_button: Button = $HUD/PauseOverlay/PausePanel/TitleButton
@onready var master_volume_slider: HSlider = $HUD/PauseOverlay/PausePanel/MasterVolumeSlider
@onready var master_volume_label: Label = $HUD/PauseOverlay/PausePanel/MasterVolumeLabel
@onready var language_button: Button = $HUD/PauseOverlay/PausePanel/LanguageButton
@onready var camera: Camera2D = $Camera

var scrolls_collected := 0
var remaining_time: float = GAME_DURATION
var game_over := false
var is_paused := false
var current_level_index := 1
var current_level: Panel
var last_health := -1
var boss_defeated := false
var _shake_strength := 0.0
var _volume_save_timer: Timer
var _objective_key := ""
var _objective_args: Array = []
var _result_message_key := ""

func _ready() -> void:
	LocalePreferences.apply_saved_locale()
	_translate_static_texts()
	process_mode = Node.PROCESS_MODE_ALWAYS
	playfield.process_mode = Node.PROCESS_MODE_PAUSABLE
	level_two.process_mode = Node.PROCESS_MODE_DISABLED
	level_three.process_mode = Node.PROCESS_MODE_DISABLED
	level_four.process_mode = Node.PROCESS_MODE_DISABLED
	level_five.process_mode = Node.PROCESS_MODE_DISABLED
	level_two.visible = false
	level_three.visible = false
	level_four.visible = false
	level_five.visible = false
	$HUD.process_mode = Node.PROCESS_MODE_PAUSABLE
	$Audio.process_mode = Node.PROCESS_MODE_PAUSABLE
	boss_panel.process_mode = Node.PROCESS_MODE_PAUSABLE
	boss_panel.visible = false
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	current_level = playfield
	_configure_ui_font_fallback()
	resume_button.pressed.connect(_resume_game)
	restart_button.pressed.connect(_restart_game)
	title_button.pressed.connect(_return_to_title)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	master_volume_slider.set_value_no_signal(_load_master_volume())
	_apply_master_volume(master_volume_slider.value)
	language_button.text = LocalePreferences.toggle_label(TranslationServer.get_locale())
	language_button.pressed.connect(_on_language_toggle_pressed)
	_volume_save_timer = Timer.new()
	_volume_save_timer.one_shot = true
	_volume_save_timer.wait_time = VOLUME_SAVE_DELAY
	_volume_save_timer.timeout.connect(_save_master_volume_settings)
	add_child(_volume_save_timer)
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	player.attack_started.connect(_on_attack_started)
	player.shuriken_started.connect(_on_attack_started)
	player.attack_hit.connect(_on_player_attack_hit)
	for level in [playfield, level_two, level_three, level_four, level_five]:
		var level_exit: Area2D = level.get_node("ExitZone") as Area2D
		level_exit.connect("player_entered", Callable(self, "_on_exit_entered"), CONNECT_DEFERRED)
	music.finished.connect(_on_music_finished)
	for pickup_node in get_tree().get_nodes_in_group("scroll_pickups"):
		var pickup: Area2D = pickup_node as Area2D
		if pickup and pickup.has_signal("collected"):
				pickup.connect("collected", Callable(self, "_on_scroll_collected"))
	for health_node in get_tree().get_nodes_in_group("health_pickups"):
		if health_node.has_signal("collected"):
			health_node.connect("collected", Callable(self, "_on_health_collected"))
	for boss_node in get_tree().get_nodes_in_group("bosses"):
		if boss_node.has_signal("health_changed"):
			boss_node.connect("health_changed", Callable(self, "_on_boss_health_changed"))
			_on_boss_health_changed(int(boss_node.get("health")), int(boss_node.get("max_health")))
		if boss_node.has_signal("defeated"):
			boss_node.connect("defeated", Callable(self, "_on_boss_defeated"))
	_on_player_health_changed(player.health, player.max_health)
	_update_scroll_hud()
	_update_timer_hud()
	_update_level_display()
	_play_audio(music)
	if WEB_PLAYTEST_BRIDGE.is_autoplay_requested():
		var playtest_bridge: Node = WEB_PLAYTEST_BRIDGE.new()
		playtest_bridge.name = "WebPlaytestBridge"
		add_child(playtest_bridge)

func _exit_tree() -> void:
	_save_master_volume_settings()
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
	_update_screen_shake(delta)
	if game_over or is_paused:
		return
	remaining_time = maxf(remaining_time - delta, 0.0)
	_update_timer_hud()
	if remaining_time <= 0.0:
		_finish_game(false, "时间到")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and (game_over or is_paused):
		get_viewport().set_input_as_handled()
		_restart_game()
		return
	if not game_over and event.is_action_pressed("pause_game"):
		if is_paused:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()

func _on_player_health_changed(current_health: int, maximum_health: int) -> void:
	if last_health >= 0 and current_health < last_health:
		_play_audio(hurt_sfx)
		_add_screen_shake(0.4)
		_flash_screen(Color(0.95, 0.2, 0.2, 1.0))
	last_health = current_health
	health_label.text = tr("生命 %d / %d") % [current_health, maximum_health]

func _on_player_attack_hit() -> void:
	_add_screen_shake(0.12)

func _set_objective(key: String, args: Array = []) -> void:
	_objective_key = key
	_objective_args = args
	objective_label.text = _translated_objective()

func _translated_objective() -> String:
	if _objective_key.is_empty():
		return ""
	var translated := tr(_objective_key)
	return translated % _objective_args if not _objective_args.is_empty() else translated

func _on_attack_started() -> void:
	_play_audio(attack_sfx)

func _on_music_finished() -> void:
	if not game_over:
		_play_audio(music)

func _on_player_died() -> void:
	_set_objective("生命耗尽")
	_finish_game(false, "忍者倒下")

func _on_exit_entered() -> void:
	if game_over:
		return
	if scrolls_collected >= SCROLL_TARGET:
		if current_level_index < 5:
			_advance_to_next_level()
		elif not boss_defeated:
			_set_objective("先击败最终 Boss")
		else:
			_finish_game(true, "任务完成")
	else:
		_set_objective("还需收集 %d 个卷轴", [SCROLL_TARGET - scrolls_collected])

func _advance_to_next_level() -> void:
	if current_level_index >= 5 or game_over:
		return
	current_level.visible = false
	current_level.process_mode = Node.PROCESS_MODE_DISABLED
	if current_level_index == 1:
		current_level = level_two
	elif current_level_index == 2:
		current_level = level_three
	elif current_level_index == 3:
		current_level = level_four
	else:
		current_level = level_five
	current_level.visible = true
	current_level.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_level_index += 1
	scrolls_collected = 0
	objective_label = current_level.get_node("ObjectiveLabel") as Label
	if current_level_index == 2:
		player.global_position = (level_two.get_node("SpawnPoint") as Marker2D).global_position
	elif current_level_index == 3:
		player.global_position = (level_three.get_node("SpawnPoint") as Marker2D).global_position
	elif current_level_index == 4:
		player.global_position = (level_four.get_node("SpawnPoint") as Marker2D).global_position
	else:
		player.global_position = (level_five.get_node("SpawnPoint") as Marker2D).global_position
	player.facing_direction = Vector2.RIGHT
	_refresh_active_level_pickup_overlaps.call_deferred()
	_update_scroll_hud()
	_update_level_display()

func _refresh_active_level_pickup_overlaps() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	for pickup_group in ["scroll_pickups", "health_pickups"]:
		for pickup_node in get_tree().get_nodes_in_group(pickup_group):
			if current_level.is_ancestor_of(pickup_node):
				var pickup_area := pickup_node as Area2D
				pickup_area.monitoring = false
				pickup_area.monitoring = true

func _on_scroll_collected() -> void:
	scrolls_collected = min(scrolls_collected + 1, SCROLL_TARGET)
	_play_audio(pickup_sfx)
	_flash_screen(Color(0.95, 0.76, 0.3, 1.0))
	_update_scroll_hud()

func _on_health_collected() -> void:
	_play_audio(pickup_sfx)
	_flash_screen(Color(0.35, 0.95, 0.45, 1.0))

func _on_boss_health_changed(current_health: int, maximum_health: int) -> void:
	boss_health_bar.max_value = maximum_health
	boss_health_bar.value = current_health
	_update_boss_display()

func _on_boss_defeated() -> void:
	boss_defeated = true
	boss_name_label.text = tr("最终 Boss 已击败")
	_add_screen_shake(0.7)
	_flash_screen(Color(0.95, 0.76, 0.3, 1.0))
	_update_boss_display()
	_update_scroll_hud()

func _update_scroll_hud() -> void:
	scroll_label.text = tr("卷轴 %d / %d") % [scrolls_collected, SCROLL_TARGET]
	if scrolls_collected >= SCROLL_TARGET:
		if current_level_index == 5 and not boss_defeated:
			_set_objective("先击败最终 Boss")
		else:
			_set_objective("出口已解锁")
	else:
		_set_objective("还需收集 %d 个卷轴", [SCROLL_TARGET - scrolls_collected])
	_update_boss_display()

func _update_boss_display() -> void:
	if current_level_index != 5 or game_over:
		boss_panel.visible = false
		$Hint.visible = true
		return
	boss_panel.visible = true
	$Hint.visible = false
	if not boss_defeated:
		boss_name_label.text = tr("最终 Boss · 星陨守将")

func _update_timer_hud() -> void:
	var total_seconds := maxi(int(ceil(remaining_time)), 0)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = tr("时间 %02d:%02d") % [minutes, seconds]

func _update_level_display() -> void:
	if current_level_index == 1:
		subtitle_label.text = tr("第一关 · 旧村小径")
	elif current_level_index == 2:
		subtitle_label.text = tr("第二关 · 石仓回廊")
	elif current_level_index == 3:
		subtitle_label.text = tr("第三关 · 竹海古道")
	elif current_level_index == 4:
		subtitle_label.text = tr("第四关 · 月影神殿")
	else:
		subtitle_label.text = tr("第五关 · 星陨天守")

func _finish_game(won: bool, message: String) -> void:
	if game_over:
		return
	game_over = true
	is_paused = false
	get_tree().paused = false
	pause_overlay.visible = false
	$Hint.visible = true
	music.stop()
	result_overlay.visible = true
	_result_message_key = message
	result_label.text = tr(message)
	restart_label.text = tr("按 R 重新开始")
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	get_tree().call_group("enemies", "set_physics_process", false)
	for projectile in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(projectile):
			projectile.call_deferred("queue_free")
	for projectile in get_tree().get_nodes_in_group("player_projectiles"):
		if is_instance_valid(projectile):
			projectile.call_deferred("queue_free")
	boss_panel.visible = false
	if won:
		_play_audio(victory_sfx)
		_flash_screen(Color(0.95, 0.76, 0.3, 1.0))
	else:
		_play_audio(hurt_sfx)
		_flash_screen(Color(0.95, 0.2, 0.2, 1.0))

func _add_screen_shake(strength: float) -> void:
	_shake_strength = minf(_shake_strength + strength, 1.0)

func _update_screen_shake(delta: float) -> void:
	if _shake_strength <= 0.0:
		return
	camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength * SCREEN_SHAKE_PIXELS
	_shake_strength = maxf(_shake_strength - SCREEN_SHAKE_DECAY * delta, 0.0)
	if _shake_strength <= 0.0:
		camera.offset = Vector2.ZERO

func _pause_game() -> void:
	if game_over or is_paused:
		return
	is_paused = true
	pause_overlay.visible = true
	get_tree().paused = true
	resume_button.grab_focus()

func _resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	pause_overlay.visible = false

func _restart_game() -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _return_to_title() -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _load_master_volume() -> float:
	var settings := ConfigFile.new()
	if settings.load(SETTINGS_PATH) != OK:
		return 1.0
	return clampf(float(settings.get_value("audio", "master_volume", 1.0)), 0.0, 1.0)

func _on_master_volume_changed(value: float) -> void:
	_apply_master_volume(value)
	_volume_save_timer.start()

func _save_master_volume_settings() -> void:
	var settings := ConfigFile.new()
	settings.load(SETTINGS_PATH)
	settings.set_value("audio", "master_volume", master_volume_slider.value)
	settings.save(SETTINGS_PATH)

func _apply_master_volume(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_linear(master_bus, clampf(value, 0.0, 1.0))
	master_volume_label.text = tr("总音量 %d%%") % roundi(clampf(value, 0.0, 1.0) * 100.0)

func _on_language_toggle_pressed() -> void:
	var new_locale := LocalePreferences.next_locale(TranslationServer.get_locale())
	TranslationServer.set_locale(new_locale)
	LocalePreferences.save_locale(new_locale)
	language_button.text = LocalePreferences.toggle_label(new_locale)
	_refresh_translated_texts()

func _refresh_translated_texts() -> void:
	_translate_static_texts()
	if game_over:
		result_label.text = tr(_result_message_key)
		restart_label.text = tr("按 R 重新开始")
		return
	_update_scroll_hud()
	_update_level_display()
	_update_timer_hud()
	health_label.text = tr("生命 %d / %d") % [player.health, player.max_health]
	_apply_master_volume(master_volume_slider.value)

func _translate_static_texts() -> void:
	$Title.text = tr("忍者夜行")
	$Hint.text = tr("WASD / 方向键：移动    Space：攻击    Esc / P：暂停    R：结束后重开")
	$HUD/ResultOverlay/ResultLabel.text = tr("任务失败")
	$HUD/ResultOverlay/RestartLabel.text = tr("按 R 重新开始")
	$HUD/PauseOverlay/PausePanel/PauseTitle.text = tr("游戏暂停")
	$HUD/PauseOverlay/PausePanel/PauseHint.text = tr("游戏已暂停，倒计时也已暂停")
	$HUD/PauseOverlay/PausePanel/ResumeButton.text = tr("继续游戏")
	$HUD/PauseOverlay/PausePanel/RestartButton.text = tr("重新开始")
	$HUD/PauseOverlay/PausePanel/TitleButton.text = tr("返回标题页")
	$HUD/PauseOverlay/PausePanel/PauseKeys.text = tr("按 Esc 或 P 继续")

func _flash_screen(color: Color) -> void:
	flash_overlay.color = color
	flash_overlay.modulate = Color(1.0, 1.0, 1.0, 0.38)
	create_tween().tween_property(flash_overlay, "modulate:a", 0.0, 0.18)

func _play_audio(audio_player: AudioStreamPlayer) -> void:
	if DisplayServer.get_name() != "headless":
		audio_player.play()
