extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var third_level_exists := ResourceLoader.exists("res://scenes/level_three.tscn")
	_check(third_level_exists, "third map scene exists")
	if not third_level_exists:
		quit(1)
		return

	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	_check(main.has_node("LevelThree"), "main scene contains the third map")
	if not main.has_node("LevelThree"):
		main.free()
		quit(1)
		return

	root.add_child(main)
	await process_frame
	await physics_frame
	var player: Node = main.get_node("Player")
	var level_three: Control = main.get_node("LevelThree") as Control
	_check(not level_three.visible, "third map starts hidden")
	_check(level_three.has_node("SpawnPoint"), "third map defines its player entrance")
	_check(level_three.has_node("ScrollPickupA") and level_three.has_node("ScrollPickupB") and level_three.has_node("ScrollPickupC"), "third map contains three scrolls")

	main.remaining_time = 123.0
	player.call("take_damage", 1)
	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 2, "first exit opens the second level")

	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 3, "second exit advances to the third level")
	_check(not main.game_over, "second exit does not complete the three-level run")
	_check(level_three.visible, "third map becomes visible")
	_check(not (main.get_node("LevelTwo") as Control).visible, "second map hides after transition")
	_check(int(player.get("health")) == 2, "player health persists through the second transition")
	_check(is_equal_approx(float(main.get("remaining_time")), 123.0), "global timer persists through the second transition")
	_check(int(main.get("scrolls_collected")) == 0, "third-level scroll counter resets")
	_check(player.global_position.distance_to((level_three.get_node("SpawnPoint") as Marker2D).global_position) < 0.1, "player appears at the third-map entrance")
	_check(main.get_node("Subtitle").text.contains("第三关"), "HUD identifies the third level")

	main.call("_on_exit_entered")
	_check(not main.game_over, "third exit remains locked until its scrolls are collected")
	for scroll_name in ["ScrollPickupA", "ScrollPickupB", "ScrollPickupC"]:
		(level_three.get_node(scroll_name) as Area2D).call("_on_body_entered", player)
	main.call("_on_exit_entered")
	_check(main.game_over, "third exit completes the game")
	_check(main.get_node("HUD/ResultOverlay/ResultLabel").text == "任务完成", "final victory appears after the third level")

	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
