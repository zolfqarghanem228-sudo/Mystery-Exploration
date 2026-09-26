@tool
class_name Out_Range_Y extends Node


@export var range_Y:float = 200
@export var owner_of_nodes:Node3D = get_owner()
@export var kill_object:bool =true:
	set(val):
		kill_object = val
		notify_property_list_changed()
var Marker:Marker3D


func _get_property_list():
	var property = []
	if !kill_object:
		property.append({
			"name":"Marker",
			"type":TYPE_OBJECT,
			"hint":PROPERTY_HINT_NODE_TYPE,
			"hint_string":"Marker3D",
			"usage":PROPERTY_USAGE_DEFAULT
		})
	return property


var last_floor_player_stand:Vector3 = Vector3()
func _process(delta: float) -> void:
	if !owner_of_nodes:return
	for child in owner_of_nodes.get_children():
		if child is Player:
			if child.is_on_floor() :
				last_floor_player_stand = child.global_position
			if child.global_position.y < -range_Y:
				child.global_position = last_floor_player_stand
		if child is Node3D:
			if child.global_position.y  < -range_Y:
				if kill_object:
					child.call_deferred("queue_free")
				else :
					child.global_position = Marker.global_position
