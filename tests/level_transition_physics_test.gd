extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	var exit_zone: Area2D = main.get_node("Playfield/ExitZone") as Area2D
	var player: Node2D = main.get_node("Player") as Node2D
	main.set("scrolls_collected", 3)
	var transition_flags := 0
	for connection in exit_zone.get_signal_connection_list("player_entered"):
		var connected_callable: Callable = connection["callable"]
		if connected_callable.get_object() == main and connected_callable.get_method() == "_on_exit_entered":
			transition_flags = int(connection["flags"])
	_check((transition_flags & CONNECT_DEFERRED) != 0, "exit transition signal is connected as deferred")
	player.global_position = exit_zone.global_position
	await physics_frame
	await physics_frame
	await process_frame
	_check(int(main.get("current_level_index")) == 2, "physical exit contact advances to level two")
	_check(main.get_node("LevelTwo").visible, "level two is visible after physical exit contact")
	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
