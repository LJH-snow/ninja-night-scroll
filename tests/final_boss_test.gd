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
	_check(level_five.has_node("HealthPickupB"), "fifth map contains a backup health pickup")
	_check(not level_five.has_node("EnemyB") and not level_five.has_node("RangedEnemyB"), "final arena avoids stacking duplicate regular enemies with the boss")
	level_five.free()

	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	TranslationServer.set_locale("zh")
	await physics_frame
	_check(main.has_node("HUD/BossPanel/BossHealthBar"), "HUD contains a boss health bar")
	var player: Node = main.get_node("Player")
	for transition in range(4):
		main.scrolls_collected = 3
		main.call("_on_exit_entered")
	var boss: Node = main.get_node("LevelFive/FinalBoss")
	_check(main.get("boss_defeated") == false, "final boss starts undefeated")
	_check(int(boss.get("max_health")) >= 6, "final boss has a larger health pool")
	_check(float(boss.get("fire_interval")) >= 2.5, "final boss gives players time between volleys")
	_check(float(boss.get("burst_projectile_speed")) <= 190.0, "final boss projectiles leave room to dodge")
	_check(main.get_node("HUD/BossPanel").visible, "boss health panel appears in the fifth level")
	var boss_panel: Control = main.get_node("HUD/BossPanel") as Control
	var playfield: Control = main.get_node("Playfield") as Control
	_check(not boss_panel.get_global_rect().intersects(playfield.get_global_rect()), "boss health panel stays outside the map")
	var title: Control = main.get_node("Title") as Control
	_check(not boss_panel.get_global_rect().intersects(title.get_global_rect()), "boss health panel does not cover the title")
	_check(not main.get_node("Hint").visible, "control hint hides while the boss panel uses the footer")
	_check(boss_panel.position.y >= main.get_node("Playfield").position.y + main.get_node("Playfield").size.y, "boss health panel stays below the playfield")

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
