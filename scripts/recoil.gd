extends Node3D

@onready var weapon: MeshInstance3D = %Weapons

var current_rotation: Vector3
var target_rotation: Vector3
var recoil_amount: Vector3 
var snap_amount: float
var speed: float

func _ready() -> void:
	weapon.weapon_fired.connect(add_recoil)

func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)

func add_recoil() -> void:
	recoil_amount = weapon.weapon.rotate_recoil_amount
	snap_amount = weapon.weapon.rotate_snap
	speed = weapon.weapon.rotate_speed
	target_rotation += Vector3(randf_range(-recoil_amount.x, recoil_amount.x * 2.0), randf_range(-recoil_amount.y, recoil_amount.y), randf_range(-recoil_amount.z, recoil_amount.z))
