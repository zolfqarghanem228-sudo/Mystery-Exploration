extends RigidBody3D
@export var node_aplity:Aplity



func _on_area_3d_body_entered(body: Node3D) -> void:
	if node_aplity.player:
		if node_aplity.player == body:
			node_aplity.give_aplity.emit(self)
			
