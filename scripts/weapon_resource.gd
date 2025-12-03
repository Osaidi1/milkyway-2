class_name weapons_resource
extends Resource

@export var Name: StringName
@export_category("Orientation")
@export var position: Vector3
@export var rotation: Vector3
@export_category("Camera Sway")
@export var camera_min := Vector2(-20.0, -20.0)
@export var camera_max := Vector2(20.0, 20.0)
@export_range(0, 0.2, 0.01) var camera_speed_position := 0.07
@export_range(0, 0.2, 0.01) var camera_speed_rotation := 0.1
@export_range(0, 0.25, 0.01) var camera_amount_position := 0.1
@export_range(0, 50, 0.1) var camera_amount_rotation := 30.0
@export_category("Idle Sway")
@export var idle_amount := 10.0
@export var idle_strength := 300.0
@export_range(0.1, 10.0, 0.1) var idle_random_amount := 5.0
@export_category("Recoil")
@export var rotate_recoil_amount: Vector3
@export var rotate_snap: float
@export var rotate_speed: float
@export var position_recoil_amount: Vector3
@export var position_snap: float
@export var position_speed: float
@export_category("Muzzle Flash")
@export var flash_time := 0.85
@export_category("Visuals")
@export var mesh_scene: Mesh
