class_name NinjaPlayer
extends CharacterBody2D

const SHURIKEN_SCENE: PackedScene = preload("res://scenes/shuriken.tscn")

const ANIM_FRAMES_PER_ROW := 4
const ANIM_IDLE_ROW := 0
const ANIM_WALK_ROW := 1
const ANIM_ATTACK_ROW := 6
const WALK_ANIM_FPS := 8.0
const IDLE_ANIM_FPS := 5.0

signal attack_started
signal shuriken_started
signal attack_finished
signal attack_hit
signal health_changed(current_health, maximum_health)
signal died

@export var speed: float = 180.0
@export var attack_duration: float = 0.14
@export var attack_cooldown: float = 0.28
@export var attack_reach: float = 32.0
@export var attack_damage: int = 1
@export var attack_knockback: float = 140.0
@export var max_health: int = 3
@export var invulnerability_duration: float = 0.5
@export var shuriken_cooldown: float = 0.45

@onready var sprite: Sprite2D = $Sprite
@onready var attack_area: Area2D = $AttackArea
@onready var attack_visual: Polygon2D = $AttackVisual

var facing_direction := Vector2.DOWN
var attack_time_left := 0.0
var attack_cooldown_left := 0.0
var shuriken_cooldown_left := 0.0
var attack_targets: Dictionary = {}
var health: int = 0
var invulnerability_time_left := 0.0
var _anim_loop_time := 0.0

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	health = max_health
	attack_area.monitoring = false
	attack_visual.visible = false
	health_changed.emit(health, max_health)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shuriken"):
		_throw_shuriken()
	elif event.is_action_pressed("attack"):
		_start_attack()

func _physics_process(delta: float) -> void:
	if invulnerability_time_left > 0.0:
		invulnerability_time_left = maxf(invulnerability_time_left - delta, 0.0)
		sprite.modulate = Color(1.0, 0.65, 0.65, 1.0)
	else:
		sprite.modulate = Color.WHITE

	if is_dead():
		velocity = Vector2.ZERO
		_set_attack_monitoring(false)
		attack_visual.visible = false
		return

	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction != Vector2.ZERO:
		facing_direction = input_direction
		sprite.flip_h = facing_direction.x < 0.0
	velocity = input_direction * speed
	move_and_slide()

	attack_cooldown_left = maxf(attack_cooldown_left - delta, 0.0)
	shuriken_cooldown_left = maxf(shuriken_cooldown_left - delta, 0.0)
	var was_attacking := attack_time_left > 0.0
	attack_time_left = maxf(attack_time_left - delta, 0.0)
	_set_attack_monitoring(attack_time_left > 0.0)
	attack_visual.visible = attack_time_left > 0.0
	_damage_attack_targets()
	_update_sprite_animation(input_direction, delta)
	if was_attacking and attack_time_left == 0.0:
		attack_finished.emit()

func _set_attack_monitoring(enabled: bool) -> void:
	if attack_area.monitoring == enabled:
		return
	attack_area.set_deferred("monitoring", enabled)

func _update_sprite_animation(input_direction: Vector2, delta: float) -> void:
	if attack_time_left > 0.0:
		var attack_progress := 1.0 - attack_time_left / maxf(attack_duration, 0.001)
		var attack_index := clampi(int(attack_progress * float(ANIM_FRAMES_PER_ROW)), 0, ANIM_FRAMES_PER_ROW - 1)
		sprite.frame = ANIM_ATTACK_ROW * ANIM_FRAMES_PER_ROW + attack_index
		return
	_anim_loop_time += delta
	if input_direction != Vector2.ZERO:
		sprite.frame = ANIM_WALK_ROW * ANIM_FRAMES_PER_ROW + int(_anim_loop_time * WALK_ANIM_FPS) % ANIM_FRAMES_PER_ROW
	else:
		sprite.frame = ANIM_IDLE_ROW * ANIM_FRAMES_PER_ROW + int(_anim_loop_time * IDLE_ANIM_FPS) % ANIM_FRAMES_PER_ROW

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

func _throw_shuriken() -> void:
	if shuriken_cooldown_left > 0.0 or is_dead():
		return
	shuriken_cooldown_left = shuriken_cooldown
	var shuriken := SHURIKEN_SCENE.instantiate() as Area2D
	get_parent().add_child(shuriken)
	shuriken.call("launch", global_position + facing_direction * 18.0, facing_direction)
	shuriken_started.emit()

func _damage_attack_targets() -> void:
	if attack_time_left <= 0.0:
		return
	var damaged_any := false
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage") and not attack_targets.has(body):
			attack_targets[body] = true
			if body.take_damage(attack_damage):
				damaged_any = true
				if body.has_method("apply_knockback"):
					body.apply_knockback(global_position.direction_to(body.global_position), attack_knockback)
	if damaged_any:
		attack_hit.emit()

func take_damage(amount: int) -> bool:
	if amount <= 0 or is_dead() or invulnerability_time_left > 0.0:
		return false
	health = maxi(health - amount, 0)
	invulnerability_time_left = invulnerability_duration
	health_changed.emit(health, max_health)
	if is_dead():
		died.emit()
	return true

func heal(amount: int) -> bool:
	if amount <= 0 or is_dead() or health >= max_health:
		return false
	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)
	return true

func is_dead() -> bool:
	return health <= 0
