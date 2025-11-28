extends Node3D

@export var weapon: weapons_resource

@onready var model: MeshInstance3D = $Model

func _ready() -> void:
	load_weapon()

func load_weapon() -> void:
	model.mesh = weapon.mesh_scene
	position = weapon.position
	rotation = weapon.rotation
	if weapon.shadow:
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	else:
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
