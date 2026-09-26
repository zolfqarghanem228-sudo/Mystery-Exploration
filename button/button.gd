extends Node3D
signal end_anim

func _ready() -> void:
	$AnimationPlayer.connect("animation_finished",_on_animation_player_animation_finished)


func _on_pressable_is_press() -> void:
	$AnimationPlayer.play("press")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "press":
		end_anim.emit()
