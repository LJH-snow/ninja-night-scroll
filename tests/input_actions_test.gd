extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "shuriken", "pause_game", "restart"]:
		_check(InputMap.has_action(action), "action exists: %s" % action)
	_check(_has_key("attack", KEY_SPACE), "attack is bound to Space")
	_check(_has_key("shuriken", KEY_SHIFT), "shuriken is bound to Shift")
	_check(_has_key("restart", KEY_R), "restart is bound to R")
	_check(_has_key("pause_game", KEY_ESCAPE), "pause is bound to Escape")
	_check(_has_key("pause_game", KEY_P), "pause is bound to P")
	_check(_has_key("move_left", KEY_A) and _has_key("move_left", KEY_LEFT), "move_left covers WASD and arrows")
	_check(_has_key("move_up", KEY_W) and _has_key("move_down", KEY_S), "move_up/down cover W and S")
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		_check(_has_joypad_input(action), "move action has a gamepad binding: %s" % action)
	for action in ["attack", "shuriken", "pause_game", "restart"]:
		_check(_has_joypad_input(action), "button action has a gamepad binding: %s" % action)
	_check(_has_joypad_button("attack", JOY_BUTTON_A) and _has_joypad_button("attack", JOY_BUTTON_X), "attack covers gamepad A and X")
	_check(_has_joypad_button("shuriken", JOY_BUTTON_Y) and _has_joypad_button("shuriken", JOY_BUTTON_RIGHT_SHOULDER), "shuriken covers gamepad Y and RB")
	_check(_has_joypad_button("pause_game", JOY_BUTTON_START), "pause covers gamepad Start")
	quit(1 if failures > 0 else 0)

func _has_key(action: String, keycode: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	for event in InputMap.action_get_events(action):
		var key_event := event as InputEventKey
		if key_event and (key_event.keycode == keycode or key_event.physical_keycode == keycode):
			return true
	return false

func _has_joypad_input(action: String) -> bool:
	if not InputMap.has_action(action):
		return false
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false

func _has_joypad_button(action: String, button_index: JoyButton) -> bool:
	if not InputMap.has_action(action):
		return false
	for event in InputMap.action_get_events(action):
		var button_event := event as InputEventJoypadButton
		if button_event and button_event.button_index == button_index:
			return true
	return false

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
