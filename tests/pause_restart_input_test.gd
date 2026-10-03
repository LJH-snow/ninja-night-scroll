extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame

	var pause_event := InputEventKey.new()
	pause_event.physical_keycode = KEY_ESCAPE
	pause_event.pressed = true
	main.call("_unhandled_input", pause_event)
	_check(bool(main.get("is_paused")), "Escape opens the pause menu")
	_check(paused, "tree is paused while the pause menu is open")

	var restart_event := InputEventKey.new()
	restart_event.physical_keycode = KEY_R
	restart_event.pressed = true
	main.call("_unhandled_input", restart_event)
	_check(not bool(main.get("is_paused")), "pressing R while paused restarts the run")
	_check(not paused, "tree is unpaused after the restart request")

	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
