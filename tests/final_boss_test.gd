extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var boss_scene_exists := ResourceLoader.exists("res://scenes/final_boss.tscn")
	_check(boss_scene_exists, "final boss scene exists")
	if not boss_scene_exists:
		quit(1)
		return

	var level_five: Node = load("res://scenes/level_five.tscn").instantiate()
	_check(level_five.has_node("FinalBoss"), "fifth map contains the final boss")
	level_five.free()

	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	_check(main.has_node("HUD/BossPanel/BossHealthBar"), "HUD contains a boss health bar")
	var player: Node = main.get_node("Player")
	for transition in range(4):
		main.scrolls_collected = 3
		main.call("_on_exit_entered")
	var boss: Node = main.get_node("LevelFive/FinalBoss")
	_check(main.get("boss_defeated") == false, "final boss starts undefeated")
	_check(int(boss.get("max_health")) >= 8, "final boss has a larger health pool")
	_check(main.get_node("HUD/BossPanel").visible, "boss health panel appears in the fifth level")

	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	_check(not main.game_over, "exit stays locked while the final boss is alive")
	var boss_health := int(boss.get("health"))
	for hit in range(boss_health):
		boss.call("take_damage", 1)
	await process_frame
	_check(main.get("boss_defeated") == true, "defeating the boss updates game state")
	main.call("_on_exit_entered")
	_check(main.game_over, "fifth exit completes after the boss is defeated")
	_check(main.get_node("HUD/ResultOverlay/ResultLabel").text == "任务完成", "boss victory shows the final result")

	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
