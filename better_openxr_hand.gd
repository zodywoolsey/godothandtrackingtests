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
	for child in get_children():
		if "target" in child:
			child.target = interface.get_hand_joint_position(hand,child.name.to_int())

func setup_hand():
	for i in range(26):
		var tmp = load("res://tracker.tscn").instantiate()
		tmp.name = str(i)
		add_child(tmp)
