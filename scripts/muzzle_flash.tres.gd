extends Node3D

@export var weapon: MeshInstance3D
@export var particles: GPUParticles3D
@export var light: OmniLight3D

var flash_time: float
var muzzle_pos: Vector3

func _ready() -> void:
	weapon.weapon_fired.connect(add_muzzle_flash)

func add_muzzle_flash() -> void:
	if !weapon.weapon.meele:
		
		flash_time = weapon.weapon.flash_time
		muzzle_pos = weapon.weapon.muzzle_position
		light.position = muzzle_pos
		particles.position = muzzle_pos
		light.visible = true
		particles.emitting = true
		await get_tree().create_timer(flash_time).timeout
		light.visible = false
		particles.emitting = false
