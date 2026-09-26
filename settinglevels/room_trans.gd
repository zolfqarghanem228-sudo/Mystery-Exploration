extends Node3D
@export var thread_instancer:ThreadInstancer
@onready var animation_player_enter_door: AnimationPlayer = $door_enter/AnimationPlayer
@onready var animation_player_exit_door: AnimationPlayer = $door_exit/AnimationPlayer
func _ready() -> void:
	if thread_instancer:
		thread_instancer.scene_ready.connect(_load_scencs)
	if get_parent() and get_parent() != get_tree().root:
		_perform_safe_transfer.call_deferred(get_tree())

func _perform_safe_transfer(tree_ref: SceneTree):
	if not tree_ref: return
	
	# حفظ الإحداثيات العالمية قبل النقل لضمان عدم تحرك الغرفة من مكانها
	var current_global_transform = global_transform
	var scene_root = tree_ref.root
	
	if get_parent():
		get_parent().remove_child(self)
	
	# الإضافة للـ Root باستخدام المرجع المحفوظ
	scene_root.add_child(self)
	
	# إعادة تعيين الإحداثيات العالمية لأن الأب الجديد (Root) يختلف عن القديم
	global_transform = current_global_transform
	print("Room transferred to Root successfully.")



func _load_scencs(dd):
	animation_player_exit_door.play("open_door")
	var COM:COM_ROOM = get_tree().get_first_node_in_group("COM_ROOM")
	if COM:
		if COM.Current_Room:
			COM.last_Room = COM.Current_Room
			COM.Current_Room = self
		elif COM.last_Room:
			COM.Current_Room = COM.last_Room
			COM.last_Room = self
		else:
			COM.Current_Room = self
func _on_body_enter_body_entered(body: Node3D) -> void:
	if body is Player:
		
		animation_player_enter_door.play("close_door")
		if thread_instancer:
			thread_instancer.start_async_load()
		$body_enter/CollisionShape3D.disabled =true
