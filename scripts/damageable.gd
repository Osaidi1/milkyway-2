class_name damageable
extends Node

@export var health: float = 100.0

var current_health: float = 0.0

func _ready() -> void:
	current_health = health

func take_damage(damage: float) -> void:
	current_health -= damage
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
