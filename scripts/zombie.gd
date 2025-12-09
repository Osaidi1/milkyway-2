class_name Zombie
extends CharacterBody3D

@export var SPEED := 3.0

@onready var player: CharacterBody3D = %Player
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _process(delta: float) -> void:
	to_player()
	
	add_gravity(delta)
	
	move_and_slide()

func to_player() -> void:
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point := nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	look_at(Vector3(player.global_position.z, global_position.y, player.global_position.z), Vector3.UP)

func add_gravity(delta) -> void:
	velocity += get_gravity() * delta
