extends Node
class_name Pressable
signal is_press
var player_pressed = false
var can_pressed = true
@export var button_obj:Node

func _ready() -> void:
	if button_obj.has_signal("end_anim"):
		button_obj.connect("end_anim",_emit_end_anim)
		self.is_press.connect(button_obj._on_pressable_is_press)

func _physics_process(delta: float) -> void:
	if player_pressed and can_pressed:
		is_press.emit()
		player_pressed = false
		can_pressed = false
		print("good")
func _emit_end_anim():
	can_pressed = true
