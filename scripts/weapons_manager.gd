@tool

extends Node3D

@export var weapon: weapons_resource:
	set(value):
		weapon = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var model: MeshInstance3D = $Model

func _ready() -> void:
	load_weapon()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		weapon = load("res://weapon_resource/ak47.tres")
		load_weapon()
	if event.is_action_pressed("weapon_down"):
		weapon = load("res://weapon_resource/crowbar.tres")
		load_weapon()

func load_weapon() -> void:
	model.mesh = weapon.mesh_scene
	position = weapon.position
	rotation = weapon.rotation
	if weapon.shadow:
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	else:
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
