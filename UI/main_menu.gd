extends Control

# Export عشان تسحب شريط التحميل من الواجهة للكود
@export var loading_bar: ProgressBar
@export_file("*.tscn") var level_path: String = "res://Level/world_prototype.tscn"

var is_loading = false

func _ready():
	# إخفاء شريط التحميل في البداية
	if loading_bar:
		loading_bar.visible = false

func _process(_delta):
	if is_loading:
		var progress = []
		# التحقق من حالة التحميل
		var status = ResourceLoader.load_threaded_get_status(level_path, progress)
		
		# تحديث قيمة شريط التحميل (progress[0] تكون قيمتها من 0 إلى 1)
		if loading_bar:
			loading_bar.value = progress[0] * 100
		
		# إذا انتهى التحميل بنجاح
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			is_loading = false
			var new_level = ResourceLoader.load_threaded_get(level_path).instantiate()
			get_tree().root.add_child(new_level)
			self.visible = false
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			print("خطأ في تحميل المرحلة")
			is_loading = false

func _on_start_pressed() -> void:
	# البدء في طلب تحميل الملف في الخلفية
	SaveManger.delete_save()
	var error = ResourceLoader.load_threaded_request(level_path)
	if error == OK:
		is_loading = true
		if loading_bar:
			loading_bar.visible = true
	else:
		print("فشل في بدء عملية التحميل")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_load_pressed() -> void:
	var loaded_room = SaveManger.load_scene_encrypted()
	if loaded_room:
		get_tree().root.add_child(loaded_room) # أو استخدم دالة الإضافة السابقة للإطباق
