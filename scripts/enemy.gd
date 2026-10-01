class_name ChasingEnemy
extends CharacterBody2D

@export var speed: float = 64.0
@export var max_health: int = 2
@export var contact_damage: int = 1
@export var contact_distance: float = 22.0
@export var contact_cooldown: float = 0.9

@onready var sprite: Sprite2D = $Sprite

var health: int = 0
var target: NinjaPlayer
var contact_cooldown_left := 0.0

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = max_health
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player") as NinjaPlayer

func _physics_process(delta: float) -> void:
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

	if global_position.distance_to(target.global_position) <= contact_distance and contact_cooldown_left <= 0.0:
		if target.take_damage(contact_damage):
			contact_cooldown_left = contact_cooldown

func take_damage(amount: int) -> bool:
	if amount <= 0 or health <= 0:
		return false
	health = maxi(health - amount, 0)
	if health == 0:
		queue_free()
	else:
		sprite.modulate = Color(1.0, 0.55, 0.55, 1.0)
		get_tree().create_timer(0.12).timeout.connect(_clear_hit_flash)
	return true

func _clear_hit_flash() -> void:
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
