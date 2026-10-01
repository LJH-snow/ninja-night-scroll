extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var fourth_level_exists := ResourceLoader.exists("res://scenes/level_four.tscn")
	_check(fourth_level_exists, "fourth map scene exists")
	if not fourth_level_exists:
		quit(1)
		return

	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	_check(main.has_node("LevelFour"), "main scene contains the fourth map")
	if not main.has_node("LevelFour"):
		main.free()
		quit(1)
		return

	root.add_child(main)
	await process_frame
	await physics_frame
	var player: Node = main.get_node("Player")
	var level_three: Control = main.get_node("LevelThree") as Control
	var level_four: Control = main.get_node("LevelFour") as Control
	var level_five: Control = main.get_node("LevelFive") as Control
	_check(not level_four.visible, "fourth map starts hidden")
	_check(level_four.has_node("SpawnPoint"), "fourth map defines its player entrance")
	_check(level_four.has_node("ExitZone"), "fourth map defines an exit")
	_check(level_four.has_node("ScrollPickupA") and level_four.has_node("ScrollPickupB") and level_four.has_node("ScrollPickupC"), "fourth map contains three scrolls")

	main.remaining_time = 96.0
	player.call("take_damage", 1)
	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 2, "first exit opens the second level")
	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 3, "second exit opens the third level")
	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 4, "third exit advances to the fourth level")
	_check(not main.game_over, "third exit does not complete the five-level run")
	_check(level_four.visible, "fourth map becomes visible")
	_check(not level_three.visible, "third map hides after transition")
	_check(int(player.get("health")) == 2, "player health persists through the fourth-level entrance")
	_check(is_equal_approx(float(main.get("remaining_time")), 96.0), "global timer persists through the fourth-level entrance")
	_check(int(main.get("scrolls_collected")) == 0, "fourth-level scroll counter resets")
	_check(player.global_position.distance_to((level_four.get_node("SpawnPoint") as Marker2D).global_position) < 0.1, "player appears at the fourth-map entrance")
	_check(main.get_node("Subtitle").text.contains("第四关"), "HUD identifies the fourth level")

	main.call("_on_exit_entered")
	_check(not main.game_over, "fourth exit remains locked until its scrolls are collected")
	for scroll_name in ["ScrollPickupA", "ScrollPickupB", "ScrollPickupC"]:
		(level_four.get_node(scroll_name) as Area2D).call("_on_body_entered", player)
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 5, "fourth exit opens the fifth level")
	_check(not main.game_over, "fourth exit does not complete the five-level run")
	_check(level_five.visible, "fifth map becomes visible after the fourth level")
	_check(main.get_node("Subtitle").text.contains("第五关"), "HUD identifies the fifth level after the fourth exit")

	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
