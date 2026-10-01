extends CharacterBody2D

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/enemy_projectile.tscn")

@export var speed: float = 58.0
@export var max_health: int = 2
@export var preferred_distance: float = 150.0
@export var distance_tolerance: float = 18.0
@export var attack_range: float = 310.0
@export var fire_interval: float = 1.45
@export var projectile_scene: PackedScene = PROJECTILE_SCENE

@onready var sprite: Sprite2D = $Sprite

var health: int = 0
var target: Node2D
var fire_cooldown_left := 0.65

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = max_health
	add_to_group("enemies")
	target = _find_player()
	sprite.modulate = Color(0.68, 0.76, 1.0, 1.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		target = _find_player()
	if not is_instance_valid(target) or _target_is_dead():
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(target.global_position)
	var distance := global_position.distance_to(target.global_position)
	if distance > preferred_distance + distance_tolerance:
		velocity = direction * speed
	elif distance < preferred_distance - distance_tolerance:
		velocity = -direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	sprite.flip_h = direction.x < 0.0

	fire_cooldown_left = maxf(fire_cooldown_left - delta, 0.0)
	if distance <= attack_range and fire_cooldown_left <= 0.0:
		_fire_at_target(direction)
		fire_cooldown_left = fire_interval

func _find_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

func _target_is_dead() -> bool:
	return target.has_method("is_dead") and bool(target.call("is_dead"))

func _fire_at_target(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	var projectile := projectile_scene.instantiate() as Area2D
	get_parent().add_child(projectile)
	projectile.call("launch", global_position + direction * 16.0, direction)

func take_damage(amount: int) -> bool:
	if amount <= 0 or health <= 0:
		return false
	health = maxi(health - amount, 0)
	if health == 0:
		call_deferred("queue_free")
	else:
		sprite.modulate = Color(1.0, 0.55, 0.55, 1.0)
		get_tree().create_timer(0.12).timeout.connect(_clear_hit_flash)
	return true

func _clear_hit_flash() -> void:
	if is_instance_valid(sprite):
		sprite.modulate = Color(0.68, 0.76, 1.0, 1.0)
