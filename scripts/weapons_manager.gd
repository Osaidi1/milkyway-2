@tool

extends Node3D

@export var weapon: weapons_resource:
	set(value):
		weapon = value
		if Engine.is_editor_hint():
			load_weapon()

var mouse_movement: Vector2

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

func weapon_sway(delta):
	mouse_movement = mouse_movement.clamp(weapon.min, weapon.max)
	position.x = lerp(position.x, weapon.position.x - (mouse_movement.x * weapon.amount_position) * delta, weapon.speed_position)
	position.y = lerp(position.y, weapon.position.y + (mouse_movement.y * weapon.amount_position) * delta, weapon.speed_position)
	rotation_degrees.y = lerp(rotation_degrees.y, weapon.rotation.y + (mouse_movement.x * weapon.amount_rotation) * delta, weapon.speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, weapon.rotation.x - (mouse_movement.y * weapon.amount_rotation) * delta, weapon.speed_rotation)
	
