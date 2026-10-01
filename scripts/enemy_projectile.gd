extends Area2D

@export var speed: float = 230.0
@export var damage: int = 1
@export var max_lifetime: float = 3.5

var direction := Vector2.ZERO
var lifetime_left := 0.0

func _ready() -> void:
	add_to_group("enemy_projectiles")
	body_entered.connect(_on_body_entered)
	lifetime_left = max_lifetime

func launch(start_position: Vector2, travel_direction: Vector2) -> void:
	global_position = start_position
	direction = travel_direction.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	global_position += direction * speed * delta
	lifetime_left -= delta
	if lifetime_left <= 0.0:
		_defer_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	_defer_free()

func _defer_free() -> void:
	if not is_queued_for_deletion():
		call_deferred("queue_free")
