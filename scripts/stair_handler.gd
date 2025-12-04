class_name stair_handler extends Node

@export_category("Refrences")
@export var player: CharacterBody3D
@export_category("Settings")
@export var surface_threshold := 0.3

func _ready() -> void:
	pass # Replace with function body.

func handle_step_climbing():
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if _check_collision_normal(collision):
			prints("Vertical Collision Found!", collision.get_normal())
			break
	
func _check_collision_normal(collison: KinematicCollision3D):
	var normal = collison.get_normal()
	if abs(normal.y) > surface_threshold:
		return false
	return true
	#1:43
