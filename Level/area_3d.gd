extends Area3D

@export var target: Node3D

func _on_body_entered(body):
	if body.name == "Player" and target:
		body.global_position = target.global_position
