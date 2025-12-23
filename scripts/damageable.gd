class_name damageable
extends CharacterBody3D

@export var health: float = 100
var old_health := 0.0

var current_health: float = health

func _ready() -> void:
	current_health = health

func take_damage(damage: float) -> void:
	old_health = current_health
	current_health -= damage
	if current_health <= 0:
		await get_tree().create_timer(1).timeout
		die()

func die() -> void:
	queue_free()
