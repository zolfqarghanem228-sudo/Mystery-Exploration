
@tool # ضروري عشان يتغير الـ Inspector وأنت بتشتغل في المحرر
class_name ThreadInstancer
extends Node

# --- إشارات ---
signal scene_ready(instance)

# --- متغيرات الـ Export الأساسية ---
@export_group("إعدادات المشهد")
@export var scene_to_load: PackedScene
@export var target_marker: Node3D # النود اللي فيه قيمة الـ Export ومكان الإطباق

@export_enum("child", "parent", "manual","tree") var addition_mode: String = "child":
	set(value):
		addition_mode = value
		notify_property_list_changed() # تطلب من Godot تحديث قائمة الـ Inspector فوراً

# هذا المتغير سيتم إظهاره فقط في حالة "manual"
var manual_target_node: NodePath
@export var kill_Node:Node 
# تخصيص ظهور المتغيرات في الـ Inspector
func _get_property_list():
	var properties = []
	if addition_mode == "manual":
		properties.append({
			"name": "manual_target_node",
			"type": TYPE_NODE_PATH, # يظهر كصندوق اختيار نود من الشجرة
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return properties

var load_thread: Thread

func _ready():
	if not Engine.is_editor_hint(): # يتجاهل التنفيذ الفعلي داخل المحرر
		load_thread = Thread.new()
		scene_ready.connect(_Killnode)
# الدالة لبدء العملية (استدعيها عند الحاجة)
func start_async_load():
	if load_thread.is_alive(): return
	if not scene_to_load: return
	
	load_thread.start(_thread_worker.bind(scene_to_load.resource_path),Thread.PRIORITY_HIGH)

func _thread_worker(path: String):
	var res = load(path)
	var instance = res.instantiate()
	call_deferred("_finalize_addition", instance)

func _finalize_addition(instance: Node3D):
	# 1. تحديد الأب (Parent) بناءً على الاختيار
	var target_parent: Node = self # افتراضياً "child"
	
	if addition_mode == "parent":
		target_parent = get_parent()
	elif addition_mode == "manual":
		if not manual_target_node.is_empty():
			target_parent = get_node(manual_target_node)
	elif addition_mode == "tree":
		target_parent = get_tree().root
	# 2. إضافة المشهد للشجرة
	target_parent.add_child(instance)
	
	# 3. البحث عن الـ Marker الداخلي (بناءً على الجروب) وعمل الإطباق
	var internal_marker = _find_marker_by_group(instance, "Marker_Aligment")
	
	if internal_marker and target_marker:
		# إطباق الـ Marker الداخلي تماماً فوق الـ target_marker الخارجي
		instance.global_transform = target_marker.global_transform * internal_marker.transform.affine_inverse()
	
	# 4. إرسال الإشارة النهائية
	scene_ready.emit(instance)
	
	if load_thread.is_started():
		load_thread.wait_to_finish()

# دالة البحث عن الجروب داخل النسخة الجديدة
func _find_marker_by_group(root: Node, group_name: String) -> Node:
	print(root)
	if root.is_in_group(group_name): return root
	for child in root.get_children():
		var found = _find_marker_by_group(child, group_name)
		if found: return found
	return null

func _exit_tree():
	if load_thread and load_thread.is_alive():
		load_thread.wait_to_finish()


func _Killnode(_D):
	if kill_Node:
		kill_Node.call_thread_safe("queue_free")
