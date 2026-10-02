class_name FinalBoss
extends CharacterBody2D

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/enemy_projectile.tscn")

signal health_changed(current_health, maximum_health)
signal defeated

@export var speed: float = 48.0
@export var max_health: int = 6
@export var preferred_distance: float = 180.0
@export var distance_tolerance: float = 24.0
@export var attack_range: float = 360.0
@export var fire_interval: float = 2.8
@export var burst_projectile_count: int = 3
@export var burst_spread: float = 0.24
@export var burst_projectile_speed: float = 185.0
@export var projectile_scene: PackedScene = PROJECTILE_SCENE

@onready var sprite: Sprite2D = $Sprite

var health: int = 0
var target: Node2D
var fire_cooldown_left := 1.1
var is_defeated := false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = max_health
	add_to_group("enemies")
	add_to_group("bosses")
	target = _find_player()
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	if is_defeated:
		return
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
		_fire_burst(direction)
		fire_cooldown_left = fire_interval

func _find_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

func _target_is_dead() -> bool:
	return target.has_method("is_dead") and bool(target.call("is_dead"))

func _fire_burst(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	var center := float(burst_projectile_count - 1) / 2.0
	for projectile_index in range(burst_projectile_count):
		var angle_offset := (float(projectile_index) - center) * burst_spread
		var projectile := projectile_scene.instantiate() as Area2D
		projectile.set("speed", burst_projectile_speed)
		get_parent().add_child(projectile)
		projectile.call("launch", global_position + direction * 20.0, direction.rotated(angle_offset))

func take_damage(amount: int) -> bool:
	if amount <= 0 or health <= 0 or is_defeated:
		return false
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		is_defeated = true
		defeated.emit()
		call_deferred("queue_free")
	else:
		sprite.modulate = Color(1.0, 0.55, 0.55, 1.0)
		get_tree().create_timer(0.12).timeout.connect(_clear_hit_flash)
	return true

func _clear_hit_flash() -> void:
	if is_instance_valid(sprite) and not is_defeated:
		sprite.modulate = Color.WHITE
