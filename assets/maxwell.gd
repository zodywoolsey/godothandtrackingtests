extends RigidBody3D

# using a static property so that a placeholder maxwell object can be used
# to set the gravity value on all the instantiated maxwells at the same itme
static var global_gravity:float

# we have to set the value in here because we can't use instance variales in 
#	a static method
func _physics_process(delta):
	gravity_scale = global_gravity
