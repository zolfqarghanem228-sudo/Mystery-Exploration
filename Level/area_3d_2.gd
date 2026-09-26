extends Area3D

var done = false

func _ready():
	$"../CanvasLayer/TextureRect".hide()

func _on_body_entered(body):
	if done:
		return
	
	if body.is_in_group("player"):
		done = true
		$"../CanvasLayer/TextureRect".show()
