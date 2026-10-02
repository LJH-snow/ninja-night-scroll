extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var bridge_script: Script = load("res://scripts/web_playtest_bridge.gd") as Script
	_check(bridge_script != null, "web playtest bridge script exists")
	if bridge_script == null:
		quit(1)
		return
	var bridge: Node = bridge_script.new()
	bridge.set("enabled", true)
	bridge.call("record_level_result", 1, 2, 3, 177.4, 3.2, false)
	var records: Array = bridge.call("get_records")
	_check(records.size() == 1, "bridge stores one level result")
	if records.size() == 1:
		var record: Dictionary = records[0]
		_check(int(record["level"]) == 1, "bridge records the level number")
		_check(int(record["scrolls"]) == 2, "bridge records collected scrolls")
		_check(int(record["health"]) == 3, "bridge records current health")
		_check(is_equal_approx(float(record["remaining_time"]), 177.4), "bridge records remaining game time")
		_check(is_equal_approx(float(record["elapsed_seconds"]), 3.2), "bridge records level elapsed time")
		_check(bool(record["exit_reached"]) == false, "bridge records exit status")
	_check(not bridge.call("is_autoplay_requested"), "headless test does not enable Web autoplay")
	_check(bool(bridge.call("query_requests_autoplay", "?playtest=autoplay")), "autoplay query is recognized")
	_check(not bool(bridge.call("query_requests_autoplay", "?playtest=manual")), "manual query does not enable autoplay")
	bridge.free()
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
