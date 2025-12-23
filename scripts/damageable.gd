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
	print(current_health)
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
