extends Node3D

@onready var weapon: MeshInstance3D = %Weapons

var position_recoil_amount: Vector3
var snap_amount: float
var speed: float
var target_position: Vector3
var current_position: Vector3

func _ready() -> void:
	weapon.weapon_fired.connect(add_recoil)

func _process(delta: float) -> void:
	target_position = lerp(target_position, Vector3.ZERO, speed * delta)
	current_position = lerp(current_position, target_position, snap_amount * delta)
	position = current_position

func add_recoil() -> void:
	position_recoil_amount = weapon.weapon.position_recoil_amount
	snap_amount = weapon.weapon.position_snap
	speed = weapon.weapon.position_speed
	target_position = Vector3(randf_range(-position_recoil_amount.x, position_recoil_amount.x), randf_range(-position_recoil_amount.y, position_recoil_amount.y), randf_range(position_recoil_amount.z, position_recoil_amount.z * 2.0))
