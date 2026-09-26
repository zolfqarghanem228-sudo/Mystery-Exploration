@tool
class_name PathfindingSystem
extends Node3D

var astar = AStar3D.new()
var blocked_points: Array = [] # لتخزين النقاط التي ضربت عائقاً

@export_group("Bake Settings")
@export var grid_size: Vector3 = Vector3(10, 10, 10):
	set(v): grid_size = v; _update_boundary_box()
@export var step: float = 1.5:
	set(v): step = max(0.2, v)
@export var drone_radius: float = 0.4
@export var safety_margin: Vector3 = Vector3(0.2, 0.2, 0.2)
@export var collision_mask: int = 1

@export_group("Storage")
@export var save_path: String = "res://drone_nav_data.res"

@export_group("Visual Debug")
@export var show_boundary: bool = true:
	set(v): show_boundary = v; _update_boundary_box()
@export var show_valid_dots: bool = true:
	set(v): show_valid_dots = v; _update_debug_dots()
@export var show_blocked_dots: bool = true:
	set(v): show_blocked_dots = v; _update_debug_dots()

@export_group("Actions")
@export var bake_now: bool = false:
	set(v): if v: _bake_grid_safe()
@export var clear_data: bool = false:
	set(v): if v: _clear_all()

func _ready():
	_update_boundary_box()
	if not Engine.is_editor_hint():
		load_data()

# --- 1. عملية الـ Bake الذكي ---
func _bake_grid_safe():
	astar.clear()
	blocked_points.clear()
	print("بدء الـ Bake... الموقع الحالي: ", global_position)
	
	var half = grid_size / 2.0
	var counter = 0
	
	var x = -half.x
	while x <= half.x:
		var y = -half.y
		while y <= half.y:
			var z = -half.z
			while z <= half.z:
				var local_pos = Vector3(x, y, z)
				var world_pos = to_global(local_pos)
				
				if not _is_blocked(world_pos):
					astar.add_point(astar.get_available_point_id(), world_pos)
				else:
					blocked_points.append(world_pos)
				
				z += step
				counter += 1
				if counter >= 500:
					await get_tree().process_frame
					counter = 0
			y += step
		x += step
		print("جاري المعالجة... X: ", int(x))

	await _connect_grid_points_safe()
	save_data()
	_update_debug_dots()
	print("انتهى! صالحة: ", astar.get_point_count(), " | محذوفة: ", blocked_points.size())

# --- 2. فحص التصادم (نظام الـ Area) ---
func _is_blocked(pos: Vector3) -> bool:
	if not is_inside_tree() or get_world_3d() == null: return false
	
	var space_state = get_world_3d().direct_space_state
	
	# الطريقة 1: فحص الـ Box (المساحة)
	var query = PhysicsShapeQueryParameters3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(drone_radius, drone_radius, drone_radius) * 2.0 + safety_margin
	query.shape = box
	query.transform = Transform3D(Basis(), pos)
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = true
	
	var result = space_state.intersect_shape(query)
	if result.size() > 0: return true

	# الطريقة 2: فحص "العمق" (للمجسمات المقلوبة)
	# نطلق شعاعين متعاكسين صغيرين جداً، إذا اصطدم أحدهما فهو جدار
	for dir in [Vector3.UP, Vector3.RIGHT, Vector3.FORWARD]:
		var ray = PhysicsRayQueryParameters3D.create(pos - dir * 0.2, pos + dir * 0.2)
		ray.collision_mask = collision_mask
		if space_state.intersect_ray(ray).size() > 0: return true
		
	return false



# --- 3. ربط النقاط (26 اتجاه) ---
func _connect_grid_points_safe():
	var ids = astar.get_point_ids()
	var counter = 0
	for id in ids:
		var pos = astar.get_point_position(id)
		for nx in [-1, 0, 1]:
			for ny in [-1, 0, 1]:
				for nz in [-1, 0, 1]:
					if nx == 0 and ny == 0 and nz == 0: continue
					var neighbor_id = astar.get_closest_point(pos + Vector3(nx, ny, nz) * step)
					if neighbor_id != id:
						var n_pos = astar.get_point_position(neighbor_id)
						if pos.distance_to(n_pos) <= step * 1.8:
							astar.connect_points(id, neighbor_id)
		counter += 1
		if counter >= 200:
			await get_tree().process_frame
			counter = 0

# --- 4. الحفظ والتحميل ---
func save_data():
	var data = {"p": {}, "c": []}
	for id in astar.get_point_ids():
		data["p"][id] = astar.get_point_position(id)
		for n in astar.get_point_connections(id): data["c"].append(Vector2i(id, n))
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file: file.store_var(data)

func load_data():
	if not FileAccess.file_exists(save_path): return
	var file = FileAccess.open(save_path, FileAccess.READ)
	var data = file.get_var()
	astar.clear()
	for id in data["p"]: astar.add_point(int(id), data["p"][id])
	for c in data["c"]: astar.connect_points(c.x, c.y)
	_update_debug_dots()

# --- 5. العرض المرئي (Debug) ---
func _update_debug_dots():
	if not is_inside_tree(): return
	for child in get_children():
		if child.name.begins_with("DebugDots_"): child.free()
	
	if show_valid_dots and astar.get_point_count() > 0:
		_create_mm("DebugDots_Valid", Array(astar.get_point_ids()).map(func(id): return astar.get_point_position(id)), Color(0, 0.8, 1))

	
	if show_blocked_dots and blocked_points.size() > 0:
		_create_mm("DebugDots_Blocked", blocked_points, Color(1, 0.2, 0.2))

func _create_mm(n_name: String, pts: Array, clr: Color):
	var mmi = MultiMeshInstance3D.new(); mmi.name = n_name
	var mm = MultiMesh.new(); mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = SphereMesh.new(); mm.mesh.radius = 0.06; mm.mesh.height = 0.12
	var mat = StandardMaterial3D.new(); mat.albedo_color = clr; mat.shading_mode = 0
	mm.mesh.material = mat
	mm.instance_count = pts.size()
	for i in range(pts.size()):
		mm.set_instance_transform(i, Transform3D(Basis(), to_local(pts[i])))
	mmi.multimesh = mm; add_child(mmi)

func _update_boundary_box():
	var old = get_node_or_null("DebugBox")
	if old: old.free()
	if not show_boundary: return
	var mi = MeshInstance3D.new(); mi.name = "DebugBox"
	mi.mesh = BoxMesh.new(); mi.mesh.size = grid_size
	var mat = StandardMaterial3D.new(); mat.transparency = 1; mat.albedo_color = Color(1, 1, 1, 0.05); mat.shading_mode = 0
	mi.material_override = mat; add_child(mi)

func _clear_all():
	astar.clear(); blocked_points.clear(); _update_debug_dots(); print("تم المسح.")

func get_drone_path(start: Vector3, end: Vector3) -> PackedVector3Array:
	if astar.get_point_count() == 0: return []
	return astar.get_point_path(astar.get_closest_point(start), astar.get_closest_point(end))
