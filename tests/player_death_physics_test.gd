extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var player: Node = load("res://scenes/player.tscn").instantiate()
	root.add_child(player)
	await process_frame
	player.call("_start_attack")
	player.call("take_damage", 3)
	await physics_frame
	quit(0)
