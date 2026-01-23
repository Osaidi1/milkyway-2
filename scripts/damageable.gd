class_name damageable
extends CharacterBody3D

var old_health := 0.0
var current_health := 0

func take_damage(damage: float) -> void:
	old_health = current_health
	current_health -= damage
