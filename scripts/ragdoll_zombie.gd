extends Skeleton3D

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	physical_bones_start_simulation()
