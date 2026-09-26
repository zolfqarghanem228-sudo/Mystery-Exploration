extends VehicleBody3D

@onready var detect_car_fliped: Node3D = $Detect_car_fliped
@onready var base_pivot: Marker3D = $base_pivot
@onready var checkground: RayCast3D = $checkground
@onready var timer_stuck: Timer = $induct_car_stuck
@export var force_Engine:float = 90
@export var if_stuck:bool =false
@export var player_is_ride:bool = false
@export var player:Player
@export var press:Pressable
@onready var head: Node3D = $SpringArm3D/head

@onready var camera_3d: Camera3D = $SpringArm3D/head/Camera3D

signal is_controled
signal is_discontroled

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * player.Sensevity)
		camera_3d.rotate_x(-event.relative.y * player.Sensevity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-60),deg_to_rad(60))
		head.rotation.y = clamp(head.rotation.y, deg_to_rad(-55),deg_to_rad(55))
		


var pos:Vector3
var wet_time:bool = false
func  _ready() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if press:
		press.is_press.connect(_is_press)
		
	for ray in detect_car_fliped.get_children():
		if ray is RayCast3D:
				ray.add_exception(self)
	is_controled.connect(_is_connected)
	is_discontroled.connect(_is_disconnected)



func fliped_car(fr):
	for raycast in detect_car_fliped.get_children():
		if raycast is RayCast3D:
			if raycast.is_colliding() and !checkground.is_colliding() :
				apply_impulse((base_pivot.global_position - raycast.get_collision_point()),-raycast.position*1.5) 
				pos = raycast.get_collision_point()
				if timer_stuck.is_stopped() and !wet_time:
					timer_stuck.start(2)
					print("good")
					wet_time = true
			elif  checkground.is_colliding():
				timer_stuck.stop()
				wet_time = false

func _is_press():
	is_controled.emit()

func move_car():
	if !player_is_ride:
		camera_3d.current = false
		brake = force_Engine/2
		return
	camera_3d.current = true
	
	engine_force = -(Input.get_action_strength("Forward") - Input.get_action_strength("Back")) * force_Engine
	steering = lerp(steering,-(Input.get_action_strength("Right") - Input.get_action_strength("Left")),0.15)
	steering = clamp(steering,deg_to_rad(-30),deg_to_rad(30))
	print(steering)
	brake = Input.get_action_strength("Jump")*force_Engine/2
	if Input.is_action_just_pressed("exit_mode"):
		is_discontroled.emit()
func _process(delta: float) -> void:
	if if_stuck:
		fliped_car(delta)
	move_car()

func _on_induct_car_stuck_timeout() -> void:
	apply_impulse(-(base_pivot.global_position-pos) *mass*get_gravity()*1.5,)
	wet_time = false



func _is_connected():
	player_is_ride = true
	player.player_ride = true
	 
func _is_disconnected():
	player.player_ride = false
	player_is_ride = false
