@tool

extends Node3D

@export var weapon: weapons_resource:
	set(value):
		weapon = value
		if Engine.is_editor_hint():
			load_weapon()
@export var sway_noise: NoiseTexture2D
@export var sway_speed := 1.2
@export var reset := false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var player: CharacterBody3D = $"../../.."

var mouse_movement: Vector2
var random_sway_x: float
var random_sway_y: float
var random_sway_amount: float
var time := 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength

func _ready() -> void:
	await owner.ready
	load_weapon()

func _process(delta: float) -> void:
	weapon_sway(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		weapon = load("res://weapon_resource/ak47.tres")
		load_weapon()
	if event.is_action_pressed("weapon_down"):
		weapon = load("res://weapon_resource/crowbar.tres")
		load_weapon()
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func load_weapon() -> void:
	self.mesh = weapon.mesh_scene
	position = weapon.position
	rotation_degrees = weapon.rotation
	idle_sway_adjustment = weapon.idle_amount
	idle_sway_rotation_strength = weapon.idle_strength
	random_sway_amount = weapon.idle_random_amount
	

func weapon_sway(delta):
	#Idle Sway
	var sway_random: float = get_sway_noise()
	var sway_random_adjusted: float = sway_random * idle_sway_adjustment
	
	time += delta * (sway_speed + sway_random)
	random_sway_x = sin(time * 1.5 * sway_random_adjusted) / random_sway_amount
	random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
	
	#Camera Sway
	mouse_movement = mouse_movement.clamp(weapon.camera_min, weapon.camera_max)
	position.x = lerp(position.x, weapon.position.x - (mouse_movement.x * weapon.camera_amount_position) * delta, weapon.camera_speed_position)
	position.y = lerp(position.y, weapon.position.y + (mouse_movement.y * weapon.camera_amount_position) * delta, weapon.camera_speed_position)
	rotation_degrees.y = lerp(rotation_degrees.y, weapon.rotation.y + (mouse_movement.x * weapon.camera_amount_rotation) * delta, weapon.camera_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, weapon.rotation.x - (mouse_movement.y * weapon.camera_amount_rotation) * delta, weapon.camera_speed_rotation)

func get_sway_noise() -> float:
	var player_pos := Vector3(0, 0, 0)
	if not Engine.is_editor_hint():
		player_pos = player.global_position
	var noise_location := sway_noise.noise.get_noise_2d(player_pos.x, player_pos.y)
	return noise_location
