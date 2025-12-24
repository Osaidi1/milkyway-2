class_name Zombie
extends damageable

@export var SPEED := 3.0
@export var ATTACK_RANGE := 2.5

@onready var player: CharacterBody3D = $"../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_flow: AnimationTree = $AnimFlow
@onready var animations: AnimationPlayer = $Animations
@onready var collision: CollisionShape3D = $Collision
@onready var ragdoll: Node3D = $Ragdoll
@onready var armature: Node3D = $Armature
@onready var ragdoll_skeleton_simulator: PhysicalBoneSimulator3D = $Ragdoll/GeneralSkeleton/PhysicalBoneSimulator3D
@onready var ragdoll_skeleton: Skeleton3D = $Ragdoll/GeneralSkeleton

var state_machine
var player_is_in_range: bool
var ragdoll_started := false 
var is_dead := false

func _ready() -> void:
	for collision in ragdoll_skeleton_simulator.get_children():
		for shape in collision.get_children():
			if shape is CollisionShape3D:
				shape.disabled = true
	state_machine = anim_flow.get("parameters/playback")
	armature.visible = true
	ragdoll.visible = false

func _process(delta: float) -> void:
	if current_health <= 0:
		is_dead = true
	
	if is_dead:
		if !ragdoll_started:
			ragdoll_started = true
			die()
	if is_dead: return
	
	animation()
	
	add_gravity(delta)
	
	move_and_slide()
	
	being_attacked()

func add_gravity(delta) -> void:
	velocity += (get_gravity() * 50) * delta

func animation() -> void:
	anim_flow.set("parameters/conditions/player nearby", player_is_in_range)
	anim_flow.set("parameters/conditions/player not nearby", !player_is_in_range)
	anim_flow.set("parameters/conditions/attack", player_in_attack_range())
	anim_flow.set("parameters/conditions/dead", has_died())
	match state_machine.get_current_node():
		"run":
			if player_is_in_range:
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point := nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
				rotate_toward_player(get_process_delta_time())
		"attack":
			var target_pos = player.global_position
			target_pos.y = global_position.y
			look_at(target_pos, Vector3.UP)
			rotation.y += PI
			velocity = Vector3.ZERO
		"idle":
			velocity = Vector3(0, 0, 0)
		"die":
			velocity = Vector3.ZERO

func player_in_attack_range() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func rotate_toward_player(delta) -> void:
	rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), 10 * delta)

func hit_finished() -> void:
	if is_dead: return
	if global_position.distance_to(player.global_position) < ATTACK_RANGE:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func has_died() -> bool:
	return current_health <= 0

func die() -> void:
	anim_flow.active = false
	animations.stop()
	velocity = Vector3.ZERO
	collision.disabled = true
	for collision in ragdoll_skeleton.get_children():
		for shape in collision.get_children():
			if shape is CollisionShape3D:
				shape.disabled = false
	armature.visible = false
	ragdoll.visible = true
	ragdoll_skeleton.physical_bones_start_simulation()
	#currently working here

func _on_player_body_entered(body: Node3D) -> void:
	if is_dead: return
	if body is Player:
		player_is_in_range = true

func _on_player_body_exited(body: Node3D) -> void:
	if is_dead: return
	if body is Player:
		player_is_in_range = false

func being_attacked() -> void:
	if is_dead: return
	if !player_is_in_range and old_health > current_health:
		player_is_in_range = true
	old_health = current_health
