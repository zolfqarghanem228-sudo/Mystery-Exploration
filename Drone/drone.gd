extends CharacterBody3D
@export var push_force = 2
@export var speedDrone:float = 3.0
@export var speed_upping:float = 2.0
@export var player_is_ride = false
@export var pivot_obj:Marker3D
@export var player:Player
@export var press:Pressable
@export var is_timed := false
@export var timer_die := 0.0
##hey body you want pathfimding just press true
@onready var camera_2_pos: Marker3D = $camera_pos
@onready var camera2_3d: Camera3D = $SubViewport/Camera3D
var timer:=0
@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
var check_is_up_of_box:bool
var Sensevity =.005
var object_graped:PhysicsBody3D
var is_graping:bool =false


signal is_controled
signal is_discontroled

func _unhandled_input(event: InputEvent) -> void:
	
	if !player_is_ride:return
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * Sensevity)
		camera_3d.rotate_x(-event.relative.y * Sensevity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80),deg_to_rad(80))


func _is_press():
	is_controled.emit()

func _ready() -> void:
	if press:
		press.is_press.connect(_is_press)
	if !player_is_ride:
		$TextureRect.visible =false
		$ColorRect.visible = false
		$ColorRect2.visible =false
	# ضبط نقطة الارتكاز لمنتصف العناصر
	$ColorRect.pivot_offset = $ColorRect.size / 2
	$TextureRect.pivot_offset = $TextureRect.size / 2
	
	# ابدأ بحجم عرض 0 (مخفي)
	$ColorRect.scale.x = 0
	$TextureRect.scale.x = 0
func _grape():
	if object_graped:
		if object_graped is RigidBody3D:
			object_graped.linear_velocity = lerp(object_graped.linear_velocity,(pivot_obj.global_transform.origin-object_graped.global_transform.origin) *5,0.15)
		elif object_graped is CharacterBody3D:
			object_graped.velocity = lerp(object_graped.velocity,(pivot_obj.global_transform.origin-object_graped.global_transform.origin) * 5,0.15)
			object_graped.move_and_slide()

func animate_side_wipe(node: Control, open: bool, duration: float = 0.4):
	
	var target_x = 1.0 if open else 0.0
	
	var tween = create_tween()
	# التحريك على المحور X فقط للفتح العرضي
	tween.tween_property(node, "scale:x", target_x, duration)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished

func pushbox():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			if !check_is_up_of_box:
				collider.apply_central_impulse(-collision.get_normal() * push_force)




func _physics_process(delta: float) -> void:

	if !player_is_ride:
		if object_graped:

			if object_graped is RigidBody3D:
				object_graped.linear_velocity = lerp(object_graped.linear_velocity,(pivot_obj.global_transform.origin-object_graped.global_transform.origin) *5,0.15)
			elif object_graped is CharacterBody3D:
				object_graped.velocity = lerp(object_graped.velocity,(pivot_obj.global_transform.origin-object_graped.global_transform.origin) * 5,0.15)
				object_graped.move_and_slide()
		return


	if Input.is_action_just_pressed("exit_mode"):
		
		player_is_ride = false
		is_discontroled.emit()
	camera2_3d.global_position = camera_2_pos.global_position
	if is_graping:
		_grape()
	if !is_graping :
			if Input.is_action_just_pressed("Grap"):
				if object_graped:
					
					$TextureRect.visible =true
					$ColorRect.visible =true
					animate_side_wipe($TextureRect,true,.5)
					animate_side_wipe($ColorRect,true,.5)
					$Grap_Area/CollisionShape3D.disabled =true
					is_graping = true
				else:
					is_graping = false
					$Grap_Area/CollisionShape3D.disabled =false
	else: 
		if Input.is_action_just_pressed("Grap"):
			animate_side_wipe($TextureRect,false,.2)
			animate_side_wipe($ColorRect,false,.2)
			is_graping = false
			object_graped = null
			$Grap_Area/CollisionShape3D.disabled =false
	
	if object_graped :
		if pivot_obj.global_position.distance_squared_to(object_graped.global_position) > 5:
			is_graping = false
			object_graped = null
			$Grap_Area/CollisionShape3D.disabled =false
	pushbox()
	camera_3d.current = true
	if Input.is_action_pressed("Jump") :
		rotation.x = lerp(rotation.x,deg_to_rad(20),0.15) 
		velocity.y = lerp(velocity.y,speed_upping,.15) 
	elif Input.is_action_pressed("sprint-down"):
		rotation.x = lerp(rotation.x,deg_to_rad(-20),0.15)
		velocity.y = lerp(velocity.y,-speed_upping,.15) 
	else :
		rotation.x = lerp(rotation.x,deg_to_rad(0),0.15)
		velocity.y = lerp(velocity.y,0.0,.15)
	var input_dir = Input.get_vector("Left","Right","Forward","Back")
	var direction = (global_transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	where_drone_is_face(input_dir)
	if direction:
		velocity.x = direction.x * speedDrone
		velocity.z = direction.z * speedDrone
	else :
		velocity.x = lerp(velocity.x,0.0,0.15)
		velocity.z = lerp(velocity.z,0.0,0.15)
	move_and_slide()

func where_drone_is_face(dir:Vector2):
	if dir:
		head.rotation.z = lerp(head.rotation.z,-dir.x * deg_to_rad(10),0.15)
		
		rotation.x = lerp(rotation.x,dir.y * deg_to_rad(20),0.15) 
	else:
		head.rotation.z = lerp(head.rotation.z,0.0,0.15)
		rotation.x = lerp(rotation.x,0.0,.15) 

func _on_grap_area_body_entered(body) -> void:
	for child in body.get_children():
		if child.get_script() == preload("res://State_Composite/composite_grape_porp.gd"):
			object_graped = body
			child.set_process(true)


func _on_grap_area_body_exited(body: Node3D) -> void:
	if !is_graping:
		for child in body.get_children():
			if child.get_script() == preload("res://State_Composite/composite_grape_porp.gd"):
				object_graped = null
				is_graping = false
				child.set_process(false)

func _on_is_discontroled() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect2.material, "shader_parameter/transition_progress", 1.0, .2)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	camera_3d.current = false
	await  get_tree().create_timer(.5).timeout
	player.player_ride = false
	$ColorRect2.visible =false
	$TextureRect.visible =false
	$ColorRect.visible =false





func _on_timer_timeout() -> void:
	player_is_ride = false
	is_discontroled.emit()
