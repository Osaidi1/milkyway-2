extends CharacterBody3D

@export var WALK_SPEED := 4.0
@export var RUN_SPEED := 6.0
@export var JUMP_VELOCITY := 4.5
@export var SENSITIVITY := 0.006
@export var BOB_FREQUENCY := 2
@export var BOB_DISTANCE := 0.05
@export var FOV := 75.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var animations: AnimationPlayer = $Animations
@onready var crouch_check: ShapeCast3D = $CrouchCheck

var speed := 0.0
var time_bob := 0.0
var is_crouching := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crouch_check.add_exception($".")

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
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Handle Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4.0)
	
	# Funcs
	head_bob(delta)
	
	fov(delta)
	
	change_speed()
	
	add_gravity(delta)
	
	move_and_slide()

func add_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func fov(delta):
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z).length()
	var velocity_clamped = clamp(horizontal_velocity, 0.5, RUN_SPEED * 2)
	var target_fov = FOV + (speed / 2) * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func crouch():
	if is_crouching and !crouch_check.is_colliding():
		animations.play_backwards("crouch")
		is_crouching = !is_crouching
	elif !is_crouching:
		animations.play("crouch")
		is_crouching = !is_crouching

func change_speed():
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
	if is_crouching:
		speed /= 3

func head_bob(delta) -> void:
	time_bob += delta * velocity.length() * float(is_on_floor())
	var pos = Vector3.ZERO
	pos.y = sin(time_bob * BOB_FREQUENCY) * BOB_DISTANCE
	pos.x = cos(time_bob * BOB_FREQUENCY / 2) * BOB_DISTANCE
	camera.transform.origin = pos

func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
