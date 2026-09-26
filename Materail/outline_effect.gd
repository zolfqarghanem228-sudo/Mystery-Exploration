@tool
class_name Outline extends Node

@export var meshes: Array[MeshInstance3D] = []

@export var enable_outline: bool = false:
	set(val):
		enable_outline = val
		_update_outline()
		notify_property_list_changed()

@export var sharp_edge: bool = false:
	set(val):
		sharp_edge = val
		_update_outline()
		notify_property_list_changed() # لتحديث عرض المتغيرات في الـ Inspector

# القيمة الخاصة بالشيدر (عادة تكون أكبر)
@export var shader_outline_width: float = 9.3:
	set(val):
		shader_outline_width = val
		_update_outline()

# القيمة الخاصة بالـ Mesh (تكون بالمتر 0.05 مثلاً)
@export var mesh_outline_width: float = 0.03:
	set(val):
		mesh_outline_width = val
		_update_outline()

@export var outline_color: Color = Color.BLACK:
	set(val):
		outline_color = val
		_update_outline()

const OUTLINE_SHADER = preload("uid://biruuaob2ukqi")


func _exit_tree() -> void:
	for mesh_instance in meshes:
		if is_instance_valid(mesh_instance):
			# 1. إزالة الـ Overlay (الشيدر)
			mesh_instance.material_overlay = null
			
			# 2. إزالة الـ Mesh المولد (الـ Sharp Edge)
			_clear_generated_outline(mesh_instance)

# هذه الدالة تخفي وتظهر المتغيرات في المحرر حسب الحاجة
func _validate_property(property: Dictionary):
	if property.name == "shader_outline_width" and sharp_edge:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "mesh_outline_width" and not sharp_edge:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _ready() -> void:
	if not Engine.is_editor_hint():
		enable_outline = false
	_update_outline()

func _update_outline():
	for mesh_instance in meshes:
		if not is_instance_valid(mesh_instance): continue
		
		_clear_generated_outline(mesh_instance)
		mesh_instance.material_overlay = null

		if enable_outline:
			if sharp_edge:
				_create_mesh_outline(mesh_instance)
			else:
				_apply_shader_outline(mesh_instance)

func _apply_shader_outline(mesh_instance: MeshInstance3D):
	var mat = OUTLINE_SHADER.duplicate()
	mesh_instance.material_overlay = mat
	if mat is ShaderMaterial:
		mat.set_shader_parameter("outline_width", shader_outline_width)
		mat.set_shader_parameter("outline_color", outline_color)

func _create_mesh_outline(mesh_instance: MeshInstance3D):
	if not mesh_instance.mesh: return
	
	# نستخدم هنا قيمة الـ mesh_outline_width المحفوظة
	var outline_mesh = mesh_instance.mesh.create_outline(mesh_outline_width)
	var outline_node = MeshInstance3D.new()
	outline_node.mesh = outline_mesh
	outline_node.name = "GeneratedOutline"
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = outline_color
	outline_node.material_override = mat
	
	mesh_instance.add_child(outline_node)
	if Engine.is_editor_hint():
		outline_node.owner = get_tree().edited_scene_root

func _clear_generated_outline(mesh_instance: MeshInstance3D):
	for child in mesh_instance.get_children():
		if child.name == "GeneratedOutline":
			child.free()
