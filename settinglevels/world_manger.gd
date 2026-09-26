extends Node3D

func _ready() -> void:
	print(get_tree().current_scene)
	SaveManger._set_owner_recursive(get_tree().current_scene,get_tree().current_scene)

func _process(delta: float) -> void:
	if $Timer.is_stopped():$Timer.start(30)

func _on_timer_timeout() -> void:
	SaveManger.save_scene_encrypted(get_tree().current_scene)
