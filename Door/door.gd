@tool
extends StaticBody3D

enum type_btn{
	PressAble,
	CompressAble
}

var animtion_finshed := false
var disco = false

@export var Type_Button:type_btn = type_btn.PressAble:
	set(val):
		Type_Button = val
		notify_property_list_changed()
var PressAble_obj:Pressable
var CompressAble_obj:Compress_Able

func  _ready() -> void:
	match Type_Button:
		type_btn.PressAble:
			if PressAble_obj:
				PressAble_obj.is_press.connect(_is_press)
		type_btn.CompressAble:
			if CompressAble_obj:
				CompressAble_obj.is_compress.connect(_is_compress)
				CompressAble_obj.is_discompress.connect(_is_discompress)

func _is_press():
	if !animtion_finshed:
		$AnimationPlayer.play("open_door")
	else:
		$AnimationPlayer.play("close_door")

func _is_compress():
	if !animtion_finshed:
		$AnimationPlayer.play("open_door")
		await $AnimationPlayer.animation_finished
		animtion_finshed = true
		if disco:
			CompressAble_obj.is_discompress.emit()
			disco = false

func _is_discompress():
	
	if animtion_finshed:
		$AnimationPlayer.play("close_door")
		return
	disco = true




func _get_property_list() :
	var properties:=[]
	match  Type_Button:
		type_btn.PressAble:
			properties.append({
			"name": "PressAble_obj",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_NODE_TYPE,
			"hint_string": "Pressable",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		type_btn.CompressAble:
			properties.append({
			"name": "CompressAble_obj",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_NODE_TYPE,
			"hint_string": "Compress_Able",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return properties


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open_door":animtion_finshed = true
	if anim_name == "close_door":animtion_finshed = false
