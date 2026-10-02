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
	player.call("take_damage", 1)
	main.scrolls_collected = 3
	main.call("_on_exit_entered")
	await physics_frame
	await physics_frame
	await process_frame
	await physics_frame
	await physics_frame
	_check(int(main.get("current_level_index")) == 2, "first exit enters level two")
	_check(int(player.get("health")) == 3, "level-two entrance heals the player")
	for index in range(3):
		var pickup: Area2D = main.get_node("LevelTwo/ScrollPickup%s" % [char(65 + index)]) as Area2D
		player.global_position = pickup.global_position
		for frame_index in range(8):
			await physics_frame
			await process_frame
			if is_instance_valid(pickup):
				print("Level two scroll %s physics frame %s; count %s; overlaps %s" % [char(65 + index), frame_index + 1, main.get("scrolls_collected"), pickup.get_overlapping_bodies()])
			else:
				print("Level two scroll %s was collected after physics frame %s" % [char(65 + index), frame_index + 1])
				break
		_check(int(main.get("scrolls_collected")) == index + 1, "level-two scroll %s increments the HUD" % [char(65 + index)])
	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
