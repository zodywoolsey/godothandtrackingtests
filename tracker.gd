extends Node3D

var target:Vector3=Vector3()
var speed:float=.3

func _physics_process(delta):
	position.x = lerpf(position.x,target.x,speed)
	position.y = lerpf(position.y,target.y,speed)
	position.z = lerpf(position.z,target.z,speed)
