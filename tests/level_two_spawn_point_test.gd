extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	_check(main.has_node("LevelTwo/SpawnPoint"), "LevelTwo has a SpawnPoint marker")
	var spawn_point := main.get_node("LevelTwo/SpawnPoint") as Node2D
	_check(spawn_point != null and spawn_point.global_position.distance_to(Vector2(222.0, 414.0)) < 0.5,
			"LevelTwo spawn keeps the documented global entrance position")

	main.set("scrolls_collected", 3)
	main.call("_on_exit_entered")
	_check(int(main.get("current_level_index")) == 2, "exiting level one with three scrolls enters level two")
	var player := main.get("player") as Node2D
	_check(player != null and spawn_point != null and player.global_position.distance_to(spawn_point.global_position) < 0.5,
			"player enters level two exactly at the SpawnPoint")

	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
