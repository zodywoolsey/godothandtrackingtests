class_name BetterOpenXRHand
extends Node3D

@export var hand:int = 0
var interface:OpenXRInterface

func _physics_process(delta):
	if XRServer.primary_interface is OpenXRInterface and get_child_count(true)==0:
		interface = XRServer.primary_interface
		if interface.is_hand_tracking_supported():
			print("setup hand")
			setup_hand()
	for child:Node3D in get_children():
		if "target" in child:
			if interface.get_hand_joint_flags(hand,child.name.to_int()) != 0:
				child.target = interface.get_hand_joint_position(hand,child.name.to_int())
				child.quaternion = interface.get_hand_joint_rotation(hand,child.name.to_int())
			#else:
				#child.hide()

func setup_hand():
	for i in range(26):
		var tmp = load("res://tracker.tscn").instantiate()
		tmp.name = str(i)
		if hand == 0:
			tmp.collision_layers += 16
		elif hand == 1:
			tmp.collision_layers += 32
		if i not in [5,10,15,20,25]:
			tmp.collision_layers = 6
		add_child(tmp)
		match i:
			0:
				var tmparea = Area3D.new()
				var tmpshape = CollisionShape3D.new()
				tmpshape.shape = SphereShape3D.new()
				tmpshape.shape.radius = .1
				tmparea.add_child(tmpshape)
				tmp.add_child(tmparea)
				tmparea.position.y = -.1
				tmparea.position.z = -.05
			1:
				var tmpbutton = load("res://3d ui/wrist/wrist_menu.tscn").instantiate()
				tmpbutton.hand = hand
				tmp.collon = false
				tmp.add_child(tmpbutton)
