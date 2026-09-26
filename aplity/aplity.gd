extends Node
class_name Aplity
signal give_aplity(body)

var speed_of_jump:float =0
@onready var player:Player = get_tree().get_first_node_in_group("player")
@export var normal_speed:float= 1
@export var impluse:float = 2
@export var speed_run:float = 2

@export var max_hight:float = 0



func  _ready() -> void:
	give_aplity.connect(_on_give_aplity)
	speed_of_jump = 2*sqrt(player.Gravity * max_hight)

func _on_give_aplity(body:PhysicsBody3D) -> void:
	player.normal_speed = normal_speed
	player.Speed_player = normal_speed
	if max_hight != 0:
		player.speed_of_jump = speed_of_jump
	player.speed_running = speed_run
	player.Force_fire_obj = impluse
	body.call_deferred("queue_free")
