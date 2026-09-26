@tool
class_name Magnetized extends Node
@export var enable_magnet = true
@export var owner_node:Node3D
@export var AreaMagnetized:Area3D
@export var force_Magntized:float = 3

@export var selceted_object_magnetzied:bool = false:
	set(val):
		selceted_object_magnetzied = val
		notify_property_list_changed()
var objectes_selected
var magnetzide_objs:=[]
var arr_maginet = []
@onready var player:Player = get_tree().get_first_node_in_group("playerr")

func _process(delta: float) -> void:
	if magnetzide_objs == []:return
	for obj in magnetzide_objs:
		if !selceted_object_magnetzied:
			if obj[0] is CharacterBody3D:
				if player.is_graping and (player.push_force > force_Magntized) and player.object_graped == obj[0]:return
				obj[0].velocity = (owner_node.global_position -obj[0].global_position) * (force_Magntized if obj[1] ==true else -force_Magntized)
				obj[0].move_and_slide()
			if obj[0] is RigidBody3D:
				if player.is_graping and (player.push_force > force_Magntized) and player.object_graped == obj[0]:return
				obj[0].linear_velocity = (owner_node.global_position -obj[0].global_position) * (force_Magntized if obj[1] ==true else -force_Magntized)
		else:
			for sel_obj in objectes_selected:
				if sel_obj != obj[0]:return
				if obj[0] is CharacterBody3D:
					if player.is_graping and (player.push_force > force_Magntized) and player.object_graped == obj[0]:return
					obj[0].velocity = (owner_node.global_position -obj[0].global_position) * (force_Magntized if obj[1] ==true else -force_Magntized)
					obj[0].move_and_slide()
				if obj[0] is RigidBody3D:
					if player.is_graping and (player.push_force > force_Magntized) and player.object_graped == obj[0]:return
					obj[0].linear_velocity = (owner_node.global_position -obj[0].global_position) * (force_Magntized if obj[1] ==true else -force_Magntized)

func _get_property_list():
	var properties := []
	if selceted_object_magnetzied:
		properties.append({
			"name": "objectes_selected",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": "24/34:PhysicsBody3D",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return properties

func _ready() -> void:
	AreaMagnetized.body_entered.connect(_body_in_field)
	AreaMagnetized.body_exited.connect(_body_out_field)
	



func _body_in_field(body:Node3D):
	for child in body.get_children():
		if child is MagnetAble:
			print(child.attraction)
			magnetzide_objs.append([body,child.attraction])

func _body_out_field(body:Node3D):
	for child in body.get_children():
		if child is MagnetAble:
			magnetzide_objs.erase([body,child.attraction])
