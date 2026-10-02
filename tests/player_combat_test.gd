extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var shuriken_scene_exists := ResourceLoader.exists("res://scenes/shuriken.tscn")
	_check(shuriken_scene_exists, "shuriken scene exists")
	if not shuriken_scene_exists:
		quit(1)
		return

	var normal_enemy: Node = load("res://scenes/enemy.tscn").instantiate()
	_check(int(normal_enemy.get("max_health")) == 1, "normal melee enemy has one health")
	normal_enemy.free()

	var arena := Node2D.new()
	root.add_child(arena)
	var player: Node2D = load("res://scenes/player.tscn").instantiate()
	var enemy: Node2D = load("res://scenes/ranged_enemy.tscn").instantiate()
	player.position = Vector2(240.0, 180.0)
	enemy.position = Vector2(270.0, 180.0)
	enemy.set("speed", 0.0)
	player.set("facing_direction", Vector2.RIGHT)
	arena.add_child(player)
	arena.add_child(enemy)
	await process_frame
	enemy.set("fire_cooldown_left", 10.0)
	player.call("_start_attack")
	for frame in range(8):
		await physics_frame
	_check(int(enemy.get("health")) == 1, "longer sword attack damages a nearby enemy")
	_check(enemy.global_position.x > 270.0, "sword hit knocks the enemy backward")

	enemy.position = Vector2(350.0, 180.0)
	player.call("_throw_shuriken")
	for frame in range(20):
		await physics_frame
	_check(not is_instance_valid(enemy) or int(enemy.get("health")) == 0, "shuriken damages a distant enemy")

	arena.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
