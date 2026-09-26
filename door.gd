extends Node3D

var open = false
var closed_rotation

func _ready():
	closed_rotation = rotation.y

func _process(delta):
	if Input.is_key_pressed(KEY_R):
		if open:
			rotation.y = closed_rotation
			open = false
		else:
			rotation.y = deg_to_rad(90)
			open = true

		await get_tree().create_timer(0.3).timeout
