extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ranged_scene_exists := ResourceLoader.exists("res://scenes/ranged_enemy.tscn")
	var projectile_scene_exists := ResourceLoader.exists("res://scenes/enemy_projectile.tscn")
	_check(ranged_scene_exists, "ranged enemy scene exists")
	_check(projectile_scene_exists, "enemy projectile scene exists")
	if not ranged_scene_exists or not projectile_scene_exists:
		quit(1)
		return

	var level_two: Node = load("res://scenes/level_two.tscn").instantiate()
	_check(level_two.has_node("RangedEnemy"), "second map contains a ranged enemy")
	level_two.free()

	await _test_projectile_damages_player()
	await _test_ranged_enemy_retreats_when_approached()
	await _test_player_attack_defeats_ranged_enemy()
	await _test_game_over_clears_projectiles()
	quit(1 if failures > 0 else 0)

func _test_projectile_damages_player() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var player: Node2D = load("res://scenes/player.tscn").instantiate()
	var enemy: Node2D = load("res://scenes/ranged_enemy.tscn").instantiate()
	player.position = Vector2(360.0, 180.0)
	enemy.position = Vector2(150.0, 180.0)
	arena.add_child(player)
	arena.add_child(enemy)
	await _wait_for_player_damage(player, 180)
	_check(int(player.get("health")) < 3, "enemy projectile damages the player")
	arena.queue_free()
	await process_frame

func _test_ranged_enemy_retreats_when_approached() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var player: Node2D = load("res://scenes/player.tscn").instantiate()
	var enemy: Node2D = load("res://scenes/ranged_enemy.tscn").instantiate()
	player.position = Vector2(240.0, 180.0)
	enemy.position = Vector2(285.0, 180.0)
	arena.add_child(player)
	arena.add_child(enemy)
	for frame in range(60):
		if enemy.global_position.distance_to(player.global_position) > 75.0:
			break
		await physics_frame
	_check(enemy.global_position.distance_to(player.global_position) > 75.0, "ranged enemy keeps space from nearby player")
	arena.queue_free()
	await process_frame

func _test_player_attack_defeats_ranged_enemy() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var player: Node2D = load("res://scenes/player.tscn").instantiate()
	var enemy: Node2D = load("res://scenes/ranged_enemy.tscn").instantiate()
	player.position = Vector2(240.0, 180.0)
	enemy.position = Vector2(252.0, 180.0)
	enemy.set("speed", 0.0)
	player.set("facing_direction", Vector2.RIGHT)
	arena.add_child(player)
	arena.add_child(enemy)
	await process_frame
	enemy.set("fire_cooldown_left", 10.0)
	player.call("_start_attack")
	await _wait_for_enemy_health(enemy, 1, 8)
	_check(int(enemy.get("health")) == 1, "player melee attack damages ranged enemy")
	for frame in range(30):
		if float(player.get("attack_cooldown_left")) <= 0.0:
			break
		await physics_frame
	player.call("_start_attack")
	await _wait_for_enemy_removal(enemy, 8)
	_check(not is_instance_valid(enemy) or enemy.is_queued_for_deletion(), "player can defeat ranged enemy")
	arena.queue_free()
	await process_frame

func _test_game_over_clears_projectiles() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var projectile: Area2D = load("res://scenes/enemy_projectile.tscn").instantiate()
	main.add_child(projectile)
	projectile.call("launch", Vector2(300.0, 200.0), Vector2.RIGHT)
	main.call("_finish_game", false, "测试结束")
	_check(projectile.is_queued_for_deletion(), "game over clears active enemy projectiles")
	main.queue_free()
	await process_frame

func _wait_for_player_damage(player: Node2D, maximum_frames: int) -> void:
	for frame in range(maximum_frames):
		if int(player.get("health")) < 3:
			return
		await physics_frame

func _wait_for_enemy_health(enemy: Node2D, expected_health: int, maximum_frames: int) -> void:
	for frame in range(maximum_frames):
		if int(enemy.get("health")) == expected_health:
			return
		await physics_frame

func _wait_for_enemy_removal(enemy: Node2D, maximum_frames: int) -> void:
	for frame in range(maximum_frames):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			return
		await physics_frame

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
