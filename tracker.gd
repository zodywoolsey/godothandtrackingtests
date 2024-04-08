extends Node3D

var target:Vector3=Vector3()
var speed:float=.3
var collon:bool = true
var collision_layers:int=6
@onready var collision_shape_3d = $RigidBody3D/CollisionShape3D
@onready var rigid_body_3d = $RigidBody3D

func _ready():
	rigid_body_3d.collision_layer = collision_layers
	rigid_body_3d.collision_mask = collision_layers
	collision_shape_3d.disabled = !collon

func _physics_process(delta):
	position.x = lerpf(position.x,target.x,speed)
	position.y = lerpf(position.y,target.y,speed)
	position.z = lerpf(position.z,target.z,speed)
