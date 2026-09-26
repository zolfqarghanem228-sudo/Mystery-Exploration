extends Camera3D

@export var sensitivity: float = 0.008

@onready var head: Node3D = get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		head.rotate_y(-event.relative.x * sensitivity)
		rotate_x(-event.relative.y * sensitivity)

		rotation.x = clamp(
			rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)
