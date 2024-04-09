## an approach to getting the raw hand tracking data by procedurally setting up
## a hand and moving all the added children to the position their name 
## corresponds to
class_name BetterOpenXRHand
extends Node3D

## hand sidedness: 0=left || 1=right
@export var hand:int = 0
#hold a reference to the xr interface for easy access
var interface:OpenXRInterface
#track the last position and rotation of the of each joint for gesture detection
var joint_positions:Array[Vector3]
var joint_rotations:Array[Vector3]

#preload the ui sound
var ui_boop = preload("res://ui boop.ogg")

func _ready():
	joint_positions.resize(26)
	joint_rotations.resize(26)

var index_pointing := false

func _physics_process(delta):
	if hand == 1:
		var index := (
			joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL].distance_to(
				joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL]
			)+
			joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL].distance_to(
				joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE]
			)+
			joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE].distance_to(
				joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_DISTAL]
			)+
			joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_DISTAL].distance_to(
				joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_TIP]
			)
		)/4.0
		print(index)
		if index < 30.0 and !index_pointing:
			index_pointing = true
		elif index > 60.0 and index_pointing:
			play_sound()
			index_pointing = false
		
	#check whether hand tracking data is available for the first time 
	#	if it is, then setup the hand
	if XRServer.primary_interface is OpenXRInterface and get_child_count(true)==0:
		interface = XRServer.primary_interface
		if interface.is_hand_tracking_supported():
			setup_hand()
	for child:Node3D in get_children():
		if "target" in child:
			if interface.get_hand_joint_flags(hand,child.name.to_int()) != 0:
				child.target = interface.get_hand_joint_position(hand,child.name.to_int())
				child.quaternion = interface.get_hand_joint_rotation(hand,child.name.to_int())
				joint_positions[child.name.to_int()] = child.position
				joint_rotations[child.name.to_int()] = child.rotation_degrees
			#else:
				#child.hide()

## setup the hand procedurally based on the 26 known hand joints
func setup_hand():
	for i in range(26):
		#instantiate a tracker to place at this joint
		var tmp = load("res://tracker.tscn").instantiate()
		#name the tracker by the int value of the hand joint for correlation
		tmp.name = str(i)
		#if left hand, add the left hand collision layer for using ui
		if hand == 0:
			tmp.collision_layers += 16
		#if right hand, add the right hand collision layer for using ui
		elif hand == 1:
			tmp.collision_layers += 32
		#if not a tip joint, remove the sided button activation col layer
		if i not in [5,10,15,20,25]:
			tmp.collision_layers = 6
		add_child(tmp)
		#if a specific join, do something special
		match i:
			#palm joint - add the grab area (this will be used for a grabbing 
			#	system that ins't purely physics based to make it easier to move
			#	objects around
			0:
				var tmparea = Area3D.new()
				var tmpshape = CollisionShape3D.new()
				tmpshape.shape = SphereShape3D.new()
				tmpshape.shape.radius = .1
				tmparea.add_child(tmpshape)
				tmp.add_child(tmparea)
				tmparea.position.y = -.1
				tmparea.position.z = -.05
			#wrist joint - add the wrist menu to the wrist joint
			#	the wrist menu already has offsets configured in it's scene 
			#	to position it better, but I might move that offset here so it
			#	can be offset procedurally for better wrist menu usability
			1:
				var tmpbutton = load("res://3d ui/wrist/wrist_menu.tscn").instantiate()
				tmpbutton.hand = hand
				#disable collision for this join to prevent weird physics
				#	behaviors with the button positions
				tmp.collon = false
				tmp.add_child(tmpbutton)

func play_sound(pitch_scale:float=1.0):
	var tmpaudio = AudioStreamPlayer3D.new()
	tmpaudio.stream = ui_boop
	tmpaudio.pitch_scale=pitch_scale
	add_child(tmpaudio)
	tmpaudio.finished.connect(tmpaudio.queue_free)
	tmpaudio.play()
