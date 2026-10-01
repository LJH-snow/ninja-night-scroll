extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	var player: Node2D = main.get_node("Player")
	var enemy: Node2D = main.get_node("Playfield/Enemy")
	_check(enemy.global_position.distance_to(player.global_position) > 450.0, "opening enemy starts at a safe distance")
	for frame in range(180):
		await physics_frame
	_check(int(player.get("health")) == 3, "player survives three seconds without immediate contact damage")

	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
