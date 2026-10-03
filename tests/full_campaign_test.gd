extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	TranslationServer.set_locale("zh")
	await physics_frame
	var player: Node = main.get_node("Player")
	player.call("take_damage", 1)
	_check(int(player.get("health")) == 2, "campaign starts with one missing health")
	await _collect_level_scrolls(main, "Playfield")
	await _enter_level(main, "Playfield", 2)
	for frame_index in range(8):
		await physics_frame
		await process_frame
	_check(int(player.get("health")) == 3, "level-two entrance pickup heals the campaign")
	_check(not is_instance_valid(main.get_node_or_null("LevelTwo/HealthPickup")), "level-two entrance consumes its health pickup")
	for level_index in range(2, 6):
		var level_name := "Level%s" % ["Two", "Three", "Four", "Five"][level_index - 2]
		await _collect_level_scrolls(main, level_name)
		if level_index == 5:
			var boss: Node = main.get_node("LevelFive/FinalBoss")
			for hit in range(int(boss.get("health"))):
				boss.call("take_damage", 1)
			await process_frame
			_check(bool(main.get("boss_defeated")), "final boss defeat updates campaign state")
			await _enter_final_exit(main)
			break
		await _enter_level(main, level_name, level_index + 1)
	_check(main.game_over, "final exit completes the campaign")
	_check(main.get_node("HUD/ResultOverlay/ResultLabel").text == "任务完成", "campaign completion displays victory")
	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _collect_level_scrolls(main: Node, level_name: String) -> void:
	var player: Node = main.get_node("Player")
	for index in range(3):
		var pickup_name := "ScrollPickup%s" % [char(65 + index)]
		var pickup: Area2D = main.get_node("%s/%s" % [level_name, pickup_name]) as Area2D
		player.global_position = pickup.global_position
		var collected := false
		for frame_index in range(8):
			await physics_frame
			await process_frame
			if not is_instance_valid(pickup):
				collected = true
				break
		_check(collected, "%s %s triggers a real pickup collision" % [level_name, pickup_name])
		_check(int(main.get("scrolls_collected")) == index + 1, "%s %s increments the HUD" % [level_name, pickup_name])

func _enter_level(main: Node, level_name: String, expected_level: int) -> void:
	var player: Node = main.get_node("Player")
	var exit_zone: Area2D = main.get_node("%s/ExitZone" % level_name) as Area2D
	player.global_position = exit_zone.global_position
	var entered := false
	for frame_index in range(8):
		await physics_frame
		await process_frame
		if int(main.get("current_level_index")) == expected_level:
			entered = true
			break
	_check(entered, "%s exit advances to level %s through physical contact" % [level_name, expected_level])
	for frame_index in range(6):
		await physics_frame
		await process_frame

func _enter_final_exit(main: Node) -> void:
	var player: Node = main.get_node("Player")
	var exit_zone: Area2D = main.get_node("LevelFive/ExitZone") as Area2D
	player.global_position = exit_zone.global_position + Vector2(120.0, 0.0)
	await physics_frame
	await physics_frame
	player.global_position = exit_zone.global_position
	for frame_index in range(8):
		await physics_frame
		await process_frame
		if main.game_over:
			return

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
