extends Node3D
@export var force_push :float= 3



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body ==self:return
	var dir = global_transform.basis.y
	if body is RigidBody3D:
		body.linear_velocity = dir * force_push
	if body is CharacterBody3D:
		body.add_collision_exception_with($MeshInstance3D/StaticBody3D)
		if "is_launching" in body:
			body.is_launching = true
		body.velocity = dir * force_push
		print(body.velocity)
