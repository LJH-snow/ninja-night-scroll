class_name WebPlaytestBridge
extends Node

const AUTOPLAY_QUERY := "playtest=autoplay"

var enabled := false
var _records: Array[Dictionary] = []
var _main: Node
var _campaign_start_msec := 0
var _campaign_start_remaining := 0.0
var _initial_health := -1

static func is_autoplay_requested() -> bool:
	if not OS.has_feature("web"):
		return false
	return bool(JavaScriptBridge.eval("window.location.href.includes('playtest=autoplay')"))

static func query_requests_autoplay(search: String) -> bool:
	var query := search
	var question_index := query.find("?")
	if question_index >= 0:
		query = query.substr(question_index + 1)
	var hash_index := query.find("#")
	if hash_index >= 0:
		query = query.substr(0, hash_index)
	return query.split("&").has(AUTOPLAY_QUERY)

func _ready() -> void:
	if not enabled:
		enabled = is_autoplay_requested()
	if not enabled:
		return
	_main = get_parent()
	call_deferred("_run_autoplay")

func record_level_result(level: int, scrolls: int, health: int, remaining_time: float, elapsed_seconds: float, exit_reached: bool) -> void:
	var record := {
		"level": level,
		"scrolls": scrolls,
		"health": health,
		"remaining_time": remaining_time,
		"elapsed_seconds": elapsed_seconds,
		"exit_reached": exit_reached
	}
	_records.append(record)
	_publish("level_%d" % level)

func get_records() -> Array:
	return _records.duplicate(true)

func _run_autoplay() -> void:
	if not is_instance_valid(_main):
		return
	_campaign_start_msec = Time.get_ticks_msec()
	_campaign_start_remaining = float(_main.get("remaining_time"))
	var player: Node2D = _main.get("player") as Node2D
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.call("take_damage", 1)
	_initial_health = int(player.get("health"))
	player.set("invulnerability_time_left", 999.0)
	_publish("started")

	for level in range(1, 6):
		await _run_level(level, player)

	_publish("complete")

func _run_level(level: int, player: Node2D) -> void:
	var level_node: Node = _level_node(level)
	var level_start_msec := Time.get_ticks_msec()
	for pickup_suffix in ["A", "B", "C"]:
		var pickup: Area2D = level_node.get_node("ScrollPickup%s" % pickup_suffix) as Area2D
		await _move_to_and_wait(player, pickup.global_position)
		if is_instance_valid(pickup):
			pickup.call("_on_body_entered", player)
		await _wait_physics(2)
	var level_scrolls := int(_main.get("scrolls_collected"))

	var exit_reached := false
	if level < 5:
		var exit_zone: Area2D = level_node.get_node("ExitZone") as Area2D
		await _move_to_and_wait(player, exit_zone.global_position)
		await _wait_physics(3)
		if int(_main.get("current_level_index")) == level:
			_main.call("_on_exit_entered")
		await _wait_physics(3)
		exit_reached = int(_main.get("current_level_index")) == level + 1
	else:
		var boss: Node = level_node.get_node("FinalBoss")
		var boss_health := int(boss.get("health"))
		for _hit in range(boss_health):
			boss.call("take_damage", 1)
			await get_tree().process_frame
		await _wait_physics(2)
		if not bool(_main.get("game_over")):
			_main.call("_on_exit_entered")
		exit_reached = bool(_main.get("game_over"))

	var remaining_time := float(_main.get("remaining_time"))
	var elapsed_seconds := float(Time.get_ticks_msec() - level_start_msec) / 1000.0
	record_level_result(level, level_scrolls, int(player.get("health")), remaining_time, elapsed_seconds, exit_reached)

func _level_node(level: int) -> Node:
	if level == 1:
		return _main.get("playfield") as Node
	if level == 2:
		return _main.get("level_two") as Node
	if level == 3:
		return _main.get("level_three") as Node
	if level == 4:
		return _main.get("level_four") as Node
	return _main.get("level_five") as Node

func _move_to_and_wait(player: Node2D, target: Vector2) -> void:
	player.global_position = target
	player.set("velocity", Vector2.ZERO)
	await _wait_physics(2)

func _wait_physics(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame
		await get_tree().process_frame

func _publish(event_name: String) -> void:
	var campaign_elapsed_seconds := 0.0
	var game_elapsed_seconds := 0.0
	if is_instance_valid(_main):
		campaign_elapsed_seconds = float(Time.get_ticks_msec() - _campaign_start_msec) / 1000.0
		game_elapsed_seconds = _campaign_start_remaining - float(_main.get("remaining_time"))
	var payload := {
		"event": event_name,
		"initial_health": _initial_health,
		"records": _records,
		"campaign_elapsed_seconds": campaign_elapsed_seconds,
		"game_elapsed_seconds": game_elapsed_seconds
	}
	print("WEB_PLAYTEST: %s" % JSON.stringify(payload))
	if not OS.has_feature("web"):
		return
	var serialized := JSON.stringify(payload)
	var title := JSON.stringify("PLAYTEST %s" % event_name)
	JavaScriptBridge.eval("window.__ninjaPlaytestResults = %s; document.title = %s;" % [serialized, title])
