class_name weapons_resource
extends Resource

@export var Name: StringName
@export_category("Orientation")
@export var position: Vector3
@export var rotation: Vector3
@export_category("Weapon Sway")
@export var min := Vector2(-20.0, -20.0)
@export var max := Vector2(20.0, 20.0)
@export_range(0, 0.2, 0.01) var speed_position := 0.07
@export_range(0, 0.2, 0.01) var speed_rotation := 0.1
@export_range(0, 0.25, 0.01) var amount_position := 0.1
@export_range(0, 50, 0.1) var amount_rotation := 30.0
@export_category("Visuals")
@export var mesh_scene: Mesh
