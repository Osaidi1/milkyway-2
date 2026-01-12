class_name Player
extends CharacterBody3D

@export var HEALTH := 50
@export var WALK_SPEED := 4.0
@export var RUN_SPEED := 6.0
@export var JUMP_VELOCITY := 5
@export var SENSITIVITY := 0.006
@export var BOB_FREQUENCY := 2
@export var BOB_DISTANCE := 0.05
@export var FOV := 75.0
@export var INTERACT_DISTANCE := 2.0
@export_category("Camera")
@export var SIDEWAYS_TILT := 1
@export var FALL_TILT_TIME := 0.3
@export var FALL_THRESHOLD := -5.5
@export_category("Weapon")
@export var WEAPON_BOB_H := 1
@export var WEAPON_BOB_V := 4
@export_category("Refrences")

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Recoil/Camera
@onready var animations: AnimationPlayer = $Animations
@onready var crouch_check: ShapeCast3D = $CrouchCheck
@onready var weapons: MeshInstance3D = %Weapons
@onready var ammo: Label = $HUD/Magazine
@onready var total_ammo: Label = $HUD/Ammo
@onready var weapon_name: Label = $"HUD/Weapon Name"

var speed := 0.0
var time_bob := 0.0
var is_crouching := false
var interact_cast_result
var fall_value := 0.0
var FALL_TILT_TIMER := 0.0
var forward_tilt_max := 1.25
var current_fall_velocity: float 
var current_health := 0
var is_dead:= false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crouch_check.add_exception($".")
	current_health = HEALTH

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

func _unhandled_input(event: InputEvent) -> void:
	# Jump
	if event.is_action_pressed("jump") and !is_crouching:
		jump()
	
	# Crouch
	if event.is_action_pressed("crouch"):
		crouch()
	
	# Rotate Camera
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if current_health <= 0:
		is_dead = true
		die()
	
	# Handle Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			weapons.weapon_bob(delta, speed, WEAPON_BOB_H * (speed / 1.5), WEAPON_BOB_V)
			weapons.weapon_sway(delta, false)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			weapons.weapon_sway(delta, true)
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		weapons.weapon_sway(delta, true)
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
	if velocity != Vector3(0, 0, 0):
		weapons.weapon_bob(delta, 2.0, 0.01, 0.025)
	
	# Funcs
	head_bob(delta)
	
	show_gun_data()
	
	fov(delta)
	
	add_gravity(delta)
	
	camera_tilt(delta)
	
	change_speed()
	
	air_procces()
	
	interact_cast()
	
	move_and_slide()

func add_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func fov(delta) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z).length()
	var velocity_clamped = clamp(horizontal_velocity, 0.5, RUN_SPEED * 2)
	var target_fov: float = FOV + (speed / 2) * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	if is_crouching:
		target_fov *= 0.7
	camera.fov = lerp(camera.fov, target_fov, delta)

func crouch() -> void:
	if is_crouching and !crouch_check.is_colliding():
		animations.play_backwards("crouch")
		is_crouching = !is_crouching
	elif !is_crouching:
		animations.play("crouch")
		is_crouching = !is_crouching

func change_speed() -> void:
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
	if is_crouching:
		speed /= 3

func head_bob(delta) -> void:
	time_bob += delta * velocity.length() * float(is_on_floor())
	var pos := Vector3.ZERO
	pos.y = sin(time_bob * BOB_FREQUENCY) * BOB_DISTANCE
	#pos.x = abs(sin(time_bob * BOB_FREQUENCY / 2) * BOB_DISTANCE)
	camera.transform.origin = pos

func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func interact():
	if interact_cast_result and interact_cast_result.has_user_signal("interacting"):
		interact_cast_result.emit_signal("interacting")

func interact_cast():
	var space_state := camera.get_world_3d().direct_space_state
	var screen_center: Vector2 = get_viewport().size / 2
	screen_center.x += 1
	screen_center.y += 1
	var origin := camera.project_ray_origin(screen_center)
	var end := origin + camera.project_ray_normal(screen_center) * INTERACT_DISTANCE
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result := space_state.intersect_ray(query)
	var current_cast_result = result.get("collider")
	if current_cast_result != interact_cast_result:
		if interact_cast_result and interact_cast_result.has_user_signal("unfocused"):
			interact_cast_result.emit_signal("unfocused")
		if current_cast_result and current_cast_result.has_user_signal("focused"):
			current_cast_result.emit_signal("focused")
	interact_cast_result = current_cast_result

func camera_tilt(delta) -> void:
	var angles := camera.rotation
	var offset := Vector3.ZERO
	var right_dot := velocity.dot(camera.global_transform.basis.x)
	var right_tilt := clampf(right_dot * deg_to_rad(SIDEWAYS_TILT), deg_to_rad(-SIDEWAYS_TILT), deg_to_rad(SIDEWAYS_TILT))
	angles.z = lerp(angles.z, -right_tilt, delta * 125)
	FALL_TILT_TIMER -= delta
	var fall_ratio = max(0.0, FALL_TILT_TIMER / FALL_TILT_TIME)
	var fall_kick_amount = fall_ratio * fall_value
	angles.x -= fall_kick_amount
	offset.y -= fall_kick_amount
	camera.position = offset
	camera.rotation = lerp(camera.rotation, angles, delta * 8.0)
	head.rotation.x = lerp(head.rotation.x, 0.0, delta * 8) - fall_kick_amount

func add_fall_kick(fall_strength: float) -> void:
	fall_value = deg_to_rad(fall_strength)
	FALL_TILT_TIMER = FALL_TILT_TIME

func check_fall_speed() -> bool:
	return current_fall_velocity < FALL_THRESHOLD

func air_procces() -> void:
	if is_on_floor():
		if check_fall_speed():
			var fall_strength = abs(current_fall_velocity) * 0.35
			add_fall_kick(fall_strength)
	current_fall_velocity = velocity.y

func show_gun_data() -> void:
	weapon_name.text = str(weapons.weapon.weapon_name)
	ammo.text = str(weapons.magazine_count)
	total_ammo.text = str(weapons.total_ammo_count)

func hit(dir) -> void:
	dir.y *= 0 
	velocity += dir * 10

func die() -> void:
	pass

func take_damage(change) -> void:
	current_health -= change
