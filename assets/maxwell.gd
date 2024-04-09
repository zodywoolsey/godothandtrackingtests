extends RigidBody3D


static var global_gravity:float:
	set(value):
		global_gravity = value
		print('global grav set')

func _physics_process(delta):
	gravity_scale = global_gravity
