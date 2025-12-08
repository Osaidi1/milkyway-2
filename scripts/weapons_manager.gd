@tool

extends Node3D

signal weapon_fired

@export var weapon: weapons_resource:
	set(value):
		weapon = value
		if Engine.is_editor_hint():
			load_weapon()

@export var sway_speed := 1.2
@export var reset := false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var player: CharacterBody3D = $"../../../../.."
@onready var delay: Timer = $Delay

var sway_noise: FastNoiseLite
var mouse_movement: Vector2
var random_sway_x: float
var random_sway_y: float
var random_sway_amount: float
var shoot_time_gone: float
var time := 0.0
var magazine_count: int
var total_ammo_count: int
var is_reloading := false
var idle_sway_adjustment
var idle_sway_rotation_strength
var weapon_bob_amount: Vector2 = Vector2.ZERO
var bullet = preload("res://small_but_mighty/bullet_decal.tscn")

func _ready() -> void:
	await owner.ready
	load_weapon()
	magazine_count = weapon.magazine_size
	total_ammo_count = weapon.start_ammo - magazine_count

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		weapon = load("res://weapon_resource/ak47.tres")
		load_weapon()
	if event.is_action_pressed("weapon_down"):
		weapon = load("res://weapon_resource/crowbar.tres")
		load_weapon()
	if event.is_action_pressed("reload"):
		reload()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _physics_process(_delta: float) -> void:
	delay.wait_time = weapon.bullet_delay
	if delay.is_stopped():
		if Input.is_action_pressed("shoot"):
			shoot()

func load_weapon() -> void:
	self.mesh = weapon.mesh_scene
	position = weapon.position
	rotation_degrees = weapon.rotation
	idle_sway_adjustment = weapon.idle_amount
	idle_sway_rotation_strength = weapon.idle_strength
	random_sway_amount = weapon.idle_random_amount

func get_sway_noise() -> float:
	var noise := sway_noise
	if noise == null: 
		return 0.0
	var player_pos := Vector3(0, 0, 0)
	if not Engine.is_editor_hint():
		player_pos = player.global_position
	return noise.get_noise_2d(player_pos.x, player_pos.y)

func weapon_sway(delta, is_idle: bool) -> void:
	mouse_movement = mouse_movement.clamp(weapon.camera_min, weapon.camera_max)
	
	if is_idle:
		#Idle Sway
		var sway_random: float = get_sway_noise()
		var sway_random_adjusted: float = sway_random * idle_sway_adjustment
		
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
	
		#Camera Sway
		position.x = lerp(position.x, weapon.position.x - (mouse_movement.x * weapon.camera_amount_position + random_sway_x) * delta, weapon.camera_speed_position)
		position.y = lerp(position.y, weapon.position.y + (mouse_movement.y * weapon.camera_amount_position + random_sway_y) * delta, weapon.camera_speed_position)
		rotation_degrees.y = lerp(rotation_degrees.y, weapon.rotation.y + (mouse_movement.x * weapon.camera_amount_rotation + (random_sway_y + idle_sway_rotation_strength)) * delta, weapon.camera_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weapon.rotation.x - (mouse_movement.y * weapon.camera_amount_rotation + (random_sway_x + idle_sway_rotation_strength)) * delta, weapon.camera_speed_rotation)
		
	else:
		#Camera Sway
		position.x = lerp(position.x, weapon.position.x - (mouse_movement.x * weapon.camera_amount_position + weapon_bob_amount.x) * delta, weapon.camera_speed_position)
		position.y = lerp(position.y, weapon.position.y + (mouse_movement.y * weapon.camera_amount_position + weapon_bob_amount.y) * delta, weapon.camera_speed_position) - (delta / 5)
		rotation_degrees.y = lerp(rotation_degrees.y, weapon.rotation.y + (mouse_movement.x * weapon.camera_amount_rotation) * delta, weapon.camera_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weapon.rotation.x - (mouse_movement.y * weapon.camera_amount_rotation) * delta, weapon.camera_speed_rotation)

func weapon_bob(delta, bob_speed: float, hbob_amount:float, vbob_amount:float) -> void:
	if weapon_bob_amount == null:
		weapon_bob_amount = Vector2.ZERO
	time += delta
	weapon_bob_amount.x = sin(time * bob_speed) * hbob_amount
	weapon_bob_amount.y = abs(cos(time * bob_speed) * vbob_amount)

func bullet_damage(pos: Vector3, normal: Vector3) -> void:
	var instance = bullet.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = pos
	instance.look_at(pos + normal, Vector3.UP)
	instance.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	await get_tree().create_timer(3).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0, 1)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()

func shoot() -> void:
	if !weapon.meele and magazine_count > 0:
		weapon_fired.emit()
		var camera = $"../.."
		var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
		var origin: Vector3 = camera.global_position
		var ray_direction: Vector3 = -camera.global_basis.z
		var end = origin + ray_direction.normalized() * weapon.shoot_range
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_bodies = true
		var result: Dictionary = space_state.intersect_ray(query)
		if result:
			bullet_damage(result.get("position"), result.get("normal"))
		if not result.is_empty():
			damage_target(result)
		shoot_time_gone = 0.0
		remove_bullets()
		delay.start()

func damage_target(result: Dictionary) -> void:
	var target = result["collider"]
	if target is damageable:
		target.take_damage(weapon.single_damage)

func remove_bullets() -> void:
	magazine_count -= 1
	if magazine_count < 1 and total_ammo_count > 0:
		reload()

func reload() -> void:
	if magazine_count == weapon.magazine_size: return
	is_reloading = true
	
	if magazine_count == 0:
		if total_ammo_count >= weapon.magazine_size:
			await get_tree().create_timer(weapon.reload_time).timeout
			magazine_count += weapon.magazine_size
			total_ammo_count -= weapon.magazine_size
		elif total_ammo_count < weapon.magazine_size:
			await get_tree().create_timer(weapon.reload_time).timeout
			magazine_count += total_ammo_count
			total_ammo_count = 0
		elif total_ammo_count == 0:
			pass
	else:
		var bullets_needed = weapon.magazine_size - magazine_count
		if total_ammo_count >= bullets_needed:
			await get_tree().create_timer(weapon.reload_time).timeout
			magazine_count = weapon.magazine_size
			total_ammo_count -= bullets_needed
		elif total_ammo_count < bullets_needed:
			await get_tree().create_timer(weapon.reload_time).timeout
			magazine_count += total_ammo_count
			total_ammo_count = 0
		elif total_ammo_count == 0:
			pass
