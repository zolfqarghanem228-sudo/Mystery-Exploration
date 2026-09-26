extends Node

# نستخدم امتداد .tscn أو .res لحفظ المشاهد
const SAVE_PATH = "user://saved_scene.tscn"

## دالة الحفظ
func save_scene_encrypted(target_node: Node):
	if not target_node:
		return
	
	# 1. إعداد الـ Owner ضروري جداً ليتم حفظ الأبناء
	_set_owner_recursive(target_node, target_node)
	
	# 2. تعليب المشهد (Packing)
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(target_node)
	
	if result == OK:
		# 3. حفظ المشهد مباشرة كملف مورد (Resource)
		# هذه الطريقة هي الأضمن والأسرع في جودوت
		var error = ResourceSaver.save(packed_scene, SAVE_PATH)
		if error == OK:
			print("تم الحفظ بنجاح في: ", SAVE_PATH)
		else:
			push_error("فشل حفظ الملف!")

## دالة التحميل
func load_scene_encrypted() -> Node:
	if not FileAccess.file_exists(SAVE_PATH):
		print("لا يوجد ملف حفظ.")
		return null
		
	# تحميل المشهد كـ Resource ثم عمل Instance له
	var packed_scene = load(SAVE_PATH)
	if packed_scene is PackedScene:
		print("تم تحميل المشهد بنجاح.")
		return packed_scene.instantiate()
	
	return null

## دالة المساعدة (لا تحذفها)
func _set_owner_recursive(node: Node, root: Node):
	for child in node.get_children():
		child.owner = root
		_set_owner_recursive(child, root)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
