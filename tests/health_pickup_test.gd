extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var pickup_scene_exists := ResourceLoader.exists("res://scenes/health_pickup.tscn")
	_check(pickup_scene_exists, "health pickup scene exists")
	if not pickup_scene_exists:
		quit(1)
		return

	var arena := Node2D.new()
	root.add_child(arena)
	var player: Node = load("res://scenes/player.tscn").instantiate()
	var pickup: Area2D = load("res://scenes/health_pickup.tscn").instantiate()
	player.position = Vector2(200.0, 180.0)
	pickup.position = player.position
	arena.add_child(player)
	arena.add_child(pickup)
	await process_frame
	pickup.call("_on_body_entered", player)
	_check(int(player.get("health")) == 3, "full-health pickup stays available")
	player.call("take_damage", 2)
	_check(int(player.get("health")) == 2, "pickup heals player who was already standing on it")
	pickup.call("_on_body_entered", player)
	_check(int(player.get("health")) == 2, "health pickup does not over-heal or repeat")

	arena.queue_free()
	await process_frame
	await _test_real_area_contact_triggers_heal()
	await _test_level_two_health_pickup_coordinates()
	quit(1 if failures > 0 else 0)

func _test_real_area_contact_triggers_heal() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var player: Node = load("res://scenes/player.tscn").instantiate()
	var pickup: Area2D = load("res://scenes/health_pickup.tscn").instantiate()
	player.position = Vector2(200.0, 180.0)
	pickup.position = player.position
	arena.add_child(player)
	arena.add_child(pickup)
	await physics_frame
	await physics_frame
	_check(pickup.get("player_in_range") == player, "real area overlap tracks the player")
	player.call("take_damage", 1)
	_check(int(player.get("health")) == 3, "real area overlap heals after later damage")
	_check(bool(pickup.get("collected_once")), "real area pickup is consumed after healing")
	await process_frame
	_check(not is_instance_valid(pickup), "real area pickup leaves the scene after healing")
	arena.queue_free()
	await process_frame

func _test_level_two_health_pickup_coordinates() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var player: Node = main.get_node("Player")
	var pickup: Area2D = main.get_node("LevelTwo/HealthPickup") as Area2D
	player.call("take_damage", 1)
	_check(int(player.get("health")) == 2, "player enters the level with one missing health")
	main.set("scrolls_collected", 3)
	main.call("_on_exit_entered")
	await physics_frame
	await physics_frame
	var distance_to_pickup: float = player.global_position.distance_to(pickup.global_position)
	print("Level two spawn %s, health pickup %s, distance %.1f" % [player.global_position, pickup.global_position, distance_to_pickup])
	_check(distance_to_pickup <= 20.0, "level-two health pickup overlaps the entrance")
	_check(absf(pickup.global_position.y - player.global_position.y) <= 12.0, "level-two health pickup lies on the entrance corridor")
	await process_frame
	await physics_frame
	await physics_frame
	await process_frame
	_check(int(player.get("health")) == 3, "level-two pickup heals the damaged player on entry")
	_check(not is_instance_valid(pickup), "level-two entry healing consumes the pickup")
	main.queue_free()
	await process_frame

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
