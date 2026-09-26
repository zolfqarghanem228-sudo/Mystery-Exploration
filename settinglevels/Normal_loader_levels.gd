@tool
class_name loader_levels extends Node

@export var New_level:PackedScene
@export var area_will_intareact:Area3D

var load_sucess = false
@export var animtion:bool = false:
	set(val):
		animtion = val
		notify_property_list_changed()
var anmtion_Node_code:Node
func _get_property_list() :
	var prop = []
	
	if animtion:
		prop.append({
			"name": "anmtion_Node_code",
			"type": TYPE_NODE_PATH, # نستخدم مسار العقدة لاختيارها من الشجرة
			"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES,
			"hint_string": "animtion_node_code", # هنا تحدد نوع النود المسموح باختياره فقط
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return prop


func _ready():
	# نطلب تحميل المشهد في الخلفية
	ResourceLoader.load_threaded_request(New_level.resource_path)
	area_will_intareact.body_entered.connect(_body_in_area)

func _process(_delta):
	var progress = [] # مصفوفة لتخزين النسبة المئوية
	var status = ResourceLoader.load_threaded_get_status(New_level.resource_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print("جاري التحميل... ", progress[0] * 100, "%")
			
		ResourceLoader.THREAD_LOAD_LOADED:
			print("تم التحميل بنجاح!")
			set_process(false) # أوقف التحديث لتجنب التكرار
			load_sucess = true
			
		ResourceLoader.THREAD_LOAD_FAILED:
			print("خطأ في التحميل!")
			OS.crash("Failed load Resources")



func _body_in_area(body):
	if body is Player:
		if anmtion_Node_code and animtion:
			if anmtion_Node_code.has_signal("_finshed_anim"):
				await anmtion_Node_code._finshed_anim
			else:
				print("Err: "+anmtion_Node_code.name+"_finshed_anim signal isnt founded ")
		_on_loading_complete()
		area_will_intareact.body_entered.disconnect(_body_in_area)

func _on_loading_complete():
	var new_scene_resource = ResourceLoader.load_threaded_get(New_level.resource_path)
	var new_scene = new_scene_resource.instantiate()
	get_tree().root.add_child(new_scene)
