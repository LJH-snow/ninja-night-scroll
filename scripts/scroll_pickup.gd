class_name ScrollPickup
extends Area2D

signal collected

var collected_once := false

func _ready() -> void:
	add_to_group("scroll_pickups")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collected_once or not body.is_in_group("player"):
		return
	collected_once = true
	collected.emit()
	call_deferred("queue_free")
