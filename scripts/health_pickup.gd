extends Area2D

signal collected

@export var heal_amount: int = 1
var collected_once := false
var player_in_range: Node2D

func _ready() -> void:
	add_to_group("health_pickups")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if collected_once or is_instance_valid(player_in_range) or not body.is_in_group("player") or not body.has_method("heal"):
		return
	player_in_range = body
	var health_signal := Callable(self, "_on_player_health_changed")
	if body.has_signal("health_changed") and not body.is_connected("health_changed", health_signal):
		body.connect("health_changed", health_signal)
	_try_heal()

func _on_body_exited(body: Node2D) -> void:
	if body != player_in_range:
		return
	var health_signal := Callable(self, "_on_player_health_changed")
	if is_instance_valid(player_in_range) and player_in_range.is_connected("health_changed", health_signal):
		player_in_range.disconnect("health_changed", health_signal)
	player_in_range = null

func _on_player_health_changed(_current_health: int, _maximum_health: int) -> void:
	_try_heal()

func _try_heal() -> void:
	if collected_once or not is_instance_valid(player_in_range):
		return
	if int(player_in_range.get("health")) >= int(player_in_range.get("max_health")):
		return
	collected_once = true
	var health_signal := Callable(self, "_on_player_health_changed")
	if player_in_range.is_connected("health_changed", health_signal):
		player_in_range.disconnect("health_changed", health_signal)
	if not bool(player_in_range.call("heal", heal_amount)):
		collected_once = false
		return
	collected.emit()
	call_deferred("queue_free")
