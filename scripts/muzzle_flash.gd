extends Node3D

@export var weapon: MeshInstance3D
@export var particles: GPUParticles3D
@export var light: OmniLight3D

var flash_time: float

func _ready() -> void:
	weapon.weapon_fired.connect(add_muzzle_flash)

func _process(delta: float) -> void:
	flash_time = weapon.weapon.flash_time

func add_muzzle_flash() -> void:
	light.visible = true
	await get_tree().create_timer(flash_time).timeout
	light.visible = false
