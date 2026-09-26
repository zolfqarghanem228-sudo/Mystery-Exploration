@tool
extends Node
class_name Compress_Able
@export var owner_node:Node3D
@export var Area: Area3D
#if you want connect signal to body you can isnt importet to put node
@export var select_object:bool = false:
	set(val):
		select_object = val
		notify_property_list_changed()

var array_interacet_obj:Array[Node]
signal is_compress
signal is_discompress


func _get_property_list() :
	var properties = []
	if select_object:
		properties.append({
			"name": "array_interacet_obj",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": "24/34:PhysicsBody3D",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	return properties
func _ready() -> void:
	if Area:
		Area.body_entered.connect(_body_enter)
		Area.body_exited.connect(_body_exit)

func _body_enter(body):
	
	if select_object:
		for child in array_interacet_obj:
			if child == body:
				is_compress.emit()
				print("com")
	
	else:
		if body != owner_node:
			is_compress.emit()
	await get_tree().create_timer(.5).timeout

func  _body_exit(body):
	if select_object:
		for child in array_interacet_obj:
			if child == body:
				is_discompress.emit()
				print("dicom")
	else:
		is_discompress.emit()
	print(body)
