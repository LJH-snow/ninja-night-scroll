class_name NinjaPlayer
extends CharacterBody2D

signal attack_started
signal attack_finished
signal health_changed(current_health, maximum_health)
signal died

@export var speed: float = 180.0
@export var attack_duration: float = 0.14
@export var attack_cooldown: float = 0.28
@export var attack_reach: float = 25.0
@export var attack_damage: int = 1
@export var max_health: int = 3
@export var invulnerability_duration: float = 0.5

@onready var sprite: Sprite2D = $Sprite
@onready var attack_area: Area2D = $AttackArea
@onready var attack_visual: Polygon2D = $AttackVisual

var facing_direction := Vector2.DOWN
var attack_time_left := 0.0
var attack_cooldown_left := 0.0
var attack_targets: Dictionary = {}
var health: int = 0
var invulnerability_time_left := 0.0

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	health = max_health
	attack_area.monitoring = false
	attack_visual.visible = false
	health_changed.emit(health, max_health)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and _is_attack_key(event):
		_start_attack()

func _physics_process(delta: float) -> void:
	if invulnerability_time_left > 0.0:
		invulnerability_time_left = maxf(invulnerability_time_left - delta, 0.0)
		sprite.modulate = Color(1.0, 0.65, 0.65, 1.0)
	else:
		sprite.modulate = Color.WHITE

	if is_dead():
		velocity = Vector2.ZERO
		attack_area.set_deferred("monitoring", false)
		attack_visual.visible = false
		return

	var input_direction := _get_movement_input()
	if input_direction != Vector2.ZERO:
		facing_direction = input_direction
		sprite.flip_h = facing_direction.x < 0.0
	velocity = input_direction * speed
	move_and_slide()

	attack_cooldown_left = maxf(attack_cooldown_left - delta, 0.0)
	var was_attacking := attack_time_left > 0.0
	attack_time_left = maxf(attack_time_left - delta, 0.0)
	attack_area.set_deferred("monitoring", attack_time_left > 0.0)
	attack_visual.visible = attack_time_left > 0.0
	_damage_attack_targets()
	if was_attacking and attack_time_left == 0.0:
		attack_finished.emit()

func _get_movement_input() -> Vector2:
	var horizontal := 0.0
	var vertical := 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		horizontal -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		horizontal += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		vertical -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		vertical += 1.0
	return Vector2(horizontal, vertical).normalized()

func _is_attack_key(event: InputEventKey) -> bool:
	return event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE

func _start_attack() -> void:
	if attack_cooldown_left > 0.0 or is_dead():
		return
	attack_cooldown_left = attack_cooldown
	attack_time_left = attack_duration
	attack_targets.clear()
	attack_area.position = facing_direction * attack_reach
	attack_visual.rotation = facing_direction.angle()
	attack_area.monitoring = true
	attack_visual.visible = true
	attack_started.emit()

func _damage_attack_targets() -> void:
	if attack_time_left <= 0.0:
		return
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage") and not attack_targets.has(body):
			attack_targets[body] = true
			body.take_damage(attack_damage)

func take_damage(amount: int) -> bool:
	if amount <= 0 or is_dead() or invulnerability_time_left > 0.0:
		return false
	health = maxi(health - amount, 0)
	invulnerability_time_left = invulnerability_duration
	health_changed.emit(health, max_health)
	if is_dead():
		died.emit()
	return true

func is_dead() -> bool:
	return health <= 0
