class_name ChasingEnemy
extends CharacterBody2D

@export var speed: float = 28.0
@export var max_health: int = 1
@export var contact_damage: int = 1
@export var contact_distance: float = 22.0
@export var contact_cooldown: float = 1.5

@onready var sprite: Sprite2D = $Sprite

var health: int = 0
var target: NinjaPlayer
var contact_cooldown_left := 0.0
var knockback_velocity := Vector2.ZERO
var _walk_anim_time := 0.0
var _base_sprite_color := Color.WHITE

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = max_health
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player") as NinjaPlayer
	_base_sprite_color = sprite.modulate

func _physics_process(delta: float) -> void:
	if knockback_velocity.length_squared() > 1.0:
		velocity = knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 520.0 * delta)
		_update_walk_animation(delta)
		return
	contact_cooldown_left = maxf(contact_cooldown_left - delta, 0.0)
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as NinjaPlayer

	if not is_instance_valid(target) or target.is_dead():
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(target.global_position)
	velocity = direction * speed
	sprite.flip_h = direction.x < 0.0
	move_and_slide()
	_update_walk_animation(delta)

	if global_position.distance_to(target.global_position) <= contact_distance and contact_cooldown_left <= 0.0:
		if target.take_damage(contact_damage):
			contact_cooldown_left = contact_cooldown

func _update_walk_animation(delta: float) -> void:
	if velocity == Vector2.ZERO:
		sprite.frame = 0
		return
	_walk_anim_time += delta
	sprite.frame = int(_walk_anim_time * 6.0) % 2

func take_damage(amount: int) -> bool:
	if amount <= 0 or health <= 0:
		return false
	health = maxi(health - amount, 0)
	if health == 0:
		call_deferred("queue_free")
	else:
		sprite.modulate = Color(5.0, 5.0, 5.0, 1.0)
		get_tree().create_timer(0.12).timeout.connect(_clear_hit_flash)
	return true

func apply_knockback(direction: Vector2, strength: float) -> void:
	knockback_velocity = direction.normalized() * strength

func _clear_hit_flash() -> void:
	if is_instance_valid(sprite):
		sprite.modulate = _base_sprite_color
