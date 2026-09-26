extends CharacterBody3D

class_name Playerr

##max hight is how much the body can riched the unit is per meter
@export_category("setting player")
@export_group("Speed-Run")
@export var Speed_player:float = 4
@export var speed_running:float =7

@export_group("Jump-Gravity")
@export var max_hight_jump: float = .5
## acclated unit per meter
@export var Gravity:float = 9.8
@export var factor_gravity_pull:float = 1

@export_group("Camera-Sensvity")
@export var Sensevity:float = 0.003
## speed unit is per meter
@export var Bob_freq:float = 2.4
@export var Bob_Amp:float = 0.08
@export var neck_rot_deg:float = 3
@export var Fov_running:float = 0

@export_group("Force-Push")
@export var Force_fire_obj = 5
#pushing force
@export var push_force = 1



var normal_fov = 0
var normal_speed = 0
@export_category("propties")
@export var player_ride:bool = false


@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
@onready var ray_cast_3d: RayCast3D = $head/Camera3D/RayCast3D
@onready var pivot_obj: Marker3D = $head/Camera3D/pivotObj
var object_graped:PhysicsBody3D
var is_graping = false
var timebob = 0
var check_is_up_of_box = false
var grapprop:Node
var speed_of_jump:float


signal player_walk
signal player_jump
signal player_fall
signal player_push
signal player_grap
signal player_press
signal player_run
signal player_mouse_move

func _ready() -> void:
	
	var touch_mode = false
	
		
	normal_fov = camera_3d.fov
	normal_speed = Speed_player
	speed_of_jump = 4.5
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _stop_player():
	camera_3d.current = !player_ride
	set_process(!player_ride)
	set_process_unhandled_input(!player_ride)
	set_process_input(!player_ride)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * Sensevity)
		camera_3d.rotate_x(-event.relative.y * Sensevity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80),deg_to_rad(80))

		player_mouse_move.emit()
	if OS.is_debug_build() :
		if event is InputEventKey:
			if event.keycode == KEY_TAB :
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * Sensevity)
		camera_3d.rotate_x(-event.relative.y * Sensevity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if event is InputEventScreenDrag:
		head.rotate_y(-event.relative.x * Sensevity)
		camera_3d.rotate_x(-event.relative.y * Sensevity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	

func _grape():
	if object_graped:
		if object_graped.global_transform.origin.distance_squared_to(global_transform.origin)>pivot_obj.global_transform.origin.length_squared()+5:
			object_graped = null
			is_graping = false
		if object_graped is RigidBody3D:
			object_graped.linear_velocity = lerp(object_graped.linear_velocity,(pivot_obj.global_transform.origin-object_graped.global_transform.origin) *5,0.15)
			player_grap.emit()
		elif object_graped is CharacterBody3D:
			object_graped.velocity = lerp(object_graped.velocity,(pivot_obj.global_transform.origin-object_graped.global_transform.origin) * 5,0.15)
			object_graped.move_and_slide()
	if Input.is_action_just_pressed("fire") and object_graped:
		for child in object_graped.get_children(true):if child is Outline: child.enable_outline = false
		if object_graped is RigidBody3D:
			object_graped.apply_impulse(Force_fire_obj*(object_graped.global_transform.origin - global_transform.origin).normalized())
		
		object_graped = null
		is_graping = false
	if  !is_graping:
		if Input.is_action_just_pressed("Grap") :
			var objec:PhysicsBody3D
			if ray_cast_3d.get_collider() is PhysicsBody3D:
				objec = ray_cast_3d.get_collider()
			if objec :
				for child in objec.get_children(true):if child is Outline: child.enable_outline = true
				if objec is StaticBody3D:return
				for child in objec.get_children() :
					
	
					if child.get_script() == preload("res://State_Composite/composite_grape_porp.gd"):
						
						object_graped = ray_cast_3d.get_collider() 
						child.player = self
						is_graping = true
						grapprop = child
						child.set_process(true)
						break
					else : 
						if grapprop:
							grapprop.set_process(false)
						is_graping = false
				
		
	else:
		if Input.is_action_just_pressed("Grap") :
			if object_graped:
				for child in object_graped.get_children():
					if child is Outline:
						child.enable_outline = false
				is_graping = false
			object_graped = null
			

func run():
	if !is_graping:
		
		if Fov_running !=0 and speed_running !=0:
			if Input.is_action_pressed("sprint-down"):
				Speed_player = speed_running
				camera_3d.fov = lerp(camera_3d.fov,Fov_running,0.15)
				player_run.emit()
			elif Input.is_action_just_released("sprint-down"):
				Speed_player = normal_speed
				while not is_equal_approx(camera_3d.fov, normal_fov):
					camera_3d.fov = lerp(camera_3d.fov, normal_fov, 0.15)
					await get_tree().process_frame
				camera_3d.fov = normal_fov




func _press():
	var objects:Node = ray_cast_3d.get_collider()
	if objects and objects.owner != null:
		for object in objects.owner.get_children():
			if object is Pressable:
				if Input.is_action_just_pressed("Grap"):
					print(!object.player_pressed)
					object.player_pressed = !object.player_pressed 
					player_press.emit()
	


var is_launching = false 

func _physics_process(delta: float) -> void:
	if is_on_floor():
		is_launching = false
	if player_ride:
		_stop_player()
		if not is_on_floor():
			if velocity.y >0:
				velocity.y -= Gravity *delta
				player_fall.emit()
			else:
				velocity.y -= factor_gravity_pull*Gravity *delta
			move_and_slide()
		return
	_stop_player()
	run()
	_grape()
	_press()
	timebob += delta * velocity.length() * float(is_on_floor())
	if not is_on_floor():
		if velocity.y >0:
			velocity.y -= Gravity *delta
		else:
			velocity.y -= factor_gravity_pull*Gravity *delta
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = speed_of_jump 
		player_jump.emit()
	var input_dir = Input.get_vector("Left","Right","Forward","Back")
	var direction = (head.global_transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	if direction and !is_launching:
		player_walk.emit()
		velocity.x = direction.x * Speed_player 
		velocity.z = direction.z * Speed_player 
	else :
		if !is_launching:
			velocity.x = move_toward(velocity.x,0,Speed_player)
			velocity.z = move_toward(velocity.z,0,Speed_player)
	camera_3d.transform.origin = headbob(timebob,input_dir)
	move_and_slide()


func headbob(time,dir:Vector2):
	var pos = Vector3.ZERO
	pos.y = sin(time * Bob_freq) *Bob_Amp
	pos.x = cos(time * Bob_freq/2) * Bob_Amp 
	if dir.x !=0 and is_on_floor():
		head.rotation.z = lerp_angle(head.rotation.z,deg_to_rad(sign(-dir.x)*neck_rot_deg),0.05 ) 
	else:
		head.rotation.z = lerp_angle(head.rotation.z,0,0.05 )

	return pos
