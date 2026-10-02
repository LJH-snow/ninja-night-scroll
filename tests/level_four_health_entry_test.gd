extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	var player: Node = main.get_node("Player")
	var level_four: Control = main.get_node("LevelFour") as Control
	var spawn: Marker2D = level_four.get_node("SpawnPoint") as Marker2D
	var pickup: Area2D = level_four.get_node("HealthPickup") as Area2D
	var pickup_distance := spawn.global_position.distance_to(pickup.global_position)
	for transition in range(3):
		if transition == 2:
			player.call("take_damage", 1)
		main.scrolls_collected = 3
		main.call("_on_exit_entered")
		if transition == 2:
			player.global_position = spawn.global_position + Vector2(0.0, -36.0)
		await _wait_for_physics()
	_check(player.global_position.distance_to(spawn.global_position + Vector2(0.0, -36.0)) < 0.1, "player carries its held direction into the fourth level")
	_check(pickup_distance <= 20.0, "fourth-level health pickup covers the entrance")
	_check(int(player.get("health")) == 3, "fourth-level entrance heals the damaged player")
	_check(not is_instance_valid(pickup), "fourth-level entrance consumes its health pickup")
	var scroll_c: Area2D = level_four.get_node("ScrollPickupC") as Area2D
	var backup_pickup: Area2D = main.get_node_or_null("LevelFour/HealthPickupB") as Area2D
	_check(is_instance_valid(backup_pickup), "fourth-level final-scroll route includes a backup health pickup")
	if is_instance_valid(backup_pickup):
		_check(scroll_c.global_position.distance_to(backup_pickup.global_position) <= 24.0, "backup health pickup lies on the final-scroll route")
		player.global_position = scroll_c.global_position
		player.set("invulnerability_time_left", 0.0)
		_check(bool(player.call("take_damage", 1)), "player can take a second hit before reaching the backup pickup")
		await _wait_for_physics()
		_check(int(player.get("health")) == 3, "backup pickup heals the player on the final-scroll route")
		_check(not is_instance_valid(backup_pickup), "backup health pickup is consumed after healing")
	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _wait_for_physics() -> void:
	for frame_index in range(8):
		await physics_frame
		await process_frame

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
