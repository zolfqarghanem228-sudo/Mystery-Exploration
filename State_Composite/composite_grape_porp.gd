extends Node

@export_range(1,180,0.05) var Fov: float = 55
@export var speed_after_graping: float = 2
@export var player: Node3D
@export var Area_Above_box: Area3D

var normal_speed: float = 5.0
@export var RigidBody: PhysicsBody3D

func _ready():
	

	if player == null:
		player = get_tree().get_first_node_in_group("player")

	if player:
		normal_speed = player.Speed_player

	if Area_Above_box:
		Area_Above_box.body_entered.connect(_Body_above_box)
		Area_Above_box.body_exited.connect(_Body_isnt_above_box)


func _physics_process(delta):
	if Area_Above_box:
		Area_Above_box.global_rotation = Vector3.ZERO


func _process(delta):
	if player == null:
		return

	if player.is_graping:
		if RigidBody is RigidBody3D:
			RigidBody.gravity_scale = 0

		var camera = player.get_tree().get_first_node_in_group("player_camera")
		if camera:
			camera.fov = lerpf(camera.fov, Fov, 0.15)

		player.Speed_player = speed_after_graping

	else:
		var camera = player.find_child("Camera3D")
		if camera:
			camera.fov = lerpf(camera.fov, 75.0, 0.15)

		player.Speed_player = normal_speed

		if RigidBody is RigidBody3D:
			RigidBody.gravity_scale = 1


func _Body_above_box(body):
	if body == player:
		player.is_graping = false
		player.object_graped = null
		player.check_is_up_of_box = true


func _Body_isnt_above_box(body):
	if body == player:
		player.check_is_up_of_box = false
