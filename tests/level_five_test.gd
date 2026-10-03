extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var fifth_level_exists := ResourceLoader.exists("res://scenes/level_five.tscn")
	_check(fifth_level_exists, "fifth map scene exists")
	if not fifth_level_exists:
		quit(1)
		return

	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	_check(main.has_node("LevelFive"), "main scene contains the fifth map")
	if not main.has_node("LevelFive"):
		main.free()
		quit(1)
		return

	root.add_child(main)
	await process_frame
	TranslationServer.set_locale("zh")
	main.call("_refresh_translated_texts")
	await physics_frame
	var player: Node = main.get_node("Player")
	var level_four: Control = main.get_node("LevelFour") as Control
	var level_five: Control = main.get_node("LevelFive") as Control
	_check(not level_five.visible, "fifth map starts hidden")
	_check(level_five.has_node("SpawnPoint"), "fifth map defines its player entrance")
	_check(level_five.has_node("ExitZone"), "fifth map defines an exit")
	_check(level_five.has_node("ScrollPickupA") and level_five.has_node("ScrollPickupB") and level_five.has_node("ScrollPickupC"), "fifth map contains three scrolls")

	main.remaining_time = 77.0
	player.call("take_damage", 1)
	for transition in range(4):
		main.scrolls_collected = 3
		main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 5, "fourth exit advances to the fifth level")
	_check(not main.game_over, "fourth exit does not complete the five-level run")
	_check(level_five.visible, "fifth map becomes visible")
	_check(not level_four.visible, "fourth map hides after transition")
	_check(int(player.get("health")) == 2, "player health persists through the fifth-level entrance")
	_check(is_equal_approx(float(main.get("remaining_time")), 77.0), "global timer persists through the fifth-level entrance")
	_check(int(main.get("scrolls_collected")) == 0, "fifth-level scroll counter resets")
	_check(player.global_position.distance_to((level_five.get_node("SpawnPoint") as Marker2D).global_position) < 0.1, "player appears at the fifth-map entrance")
	_check(main.get_node("Subtitle").text.contains("第五关"), "HUD identifies the fifth level")

	main.call("_on_exit_entered")
	_check(not main.game_over, "fifth exit remains locked until its scrolls are collected")
	for scroll_name in ["ScrollPickupA", "ScrollPickupB", "ScrollPickupC"]:
		(level_five.get_node(scroll_name) as Area2D).call("_on_body_entered", player)
	main.call("_on_exit_entered")
	_check(not main.game_over, "fifth exit stays locked while the boss is alive")
	var boss: Node = level_five.get_node("FinalBoss")
	for hit in range(int(boss.get("health"))):
		boss.call("take_damage", 1)
	await process_frame
	_check(main.get("boss_defeated") == true, "fifth-level boss is defeated")
	main.call("_on_exit_entered")
	_check(main.game_over, "fifth exit completes the game")
	_check(main.get_node("HUD/ResultOverlay/ResultLabel").text == "任务完成", "final victory appears after the fifth level")

	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
