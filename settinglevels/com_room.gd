@tool
class_name COM_ROOM extends Node
var last_Room:Node
var Current_Room:Node

func _ready() -> void:
	if !self.is_in_group("COM_ROOM"):
		add_to_group("COM_ROOM",true)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	if last_Room and Current_Room:
		last_Room.queue_free.call_deferred()
		
		last_Room = Current_Room
		Current_Room = null
