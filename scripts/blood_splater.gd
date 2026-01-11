extends GPUParticles3D

@onready var wound_sound: AudioStreamPlayer3D = $"Wound Sound"

func _ready() -> void:
	emitting = true
	wound_sound.play
	await get_tree().create_timer(0.5, false).timeout
	queue_free()
