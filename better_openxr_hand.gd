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
var index_cumulative_angle : float = 0.0
var index_closedness : float = 0.0
var middle_pointing := false
var middle_cumulative_angle : float = 0.0
var middle_closedness : float = 0.0
var ring_pointing := false
var ring_cumulative_angle : float = 0.0
var ring_closedness : float = 0.0
var little_pointing := false
var little_cumulative_angle : float = 0.0
var little_closedness : float = 0.0
var thumb_pointing := false
var thumb_cumulative_angle : float = 0.0
var thumb_closedness : float = 0.0

var finger_activation_distance:float=40.0

func _physics_process(delta):
	index_cumulative_angle = index_finger()
	middle_cumulative_angle = middle_finger()
	ring_cumulative_angle = ring_finger()
	little_cumulative_angle = little_finger()
	thumb_cumulative_angle = thumb_finger()
	index_closedness = (remap(index_cumulative_angle,0.0,180.0,0.0,1.0))
	middle_closedness = (remap(middle_cumulative_angle,0.0,180.0,0.0,1.0))
	ring_closedness = (remap(ring_cumulative_angle,0.0,180.0,0.0,1.0))
	little_closedness = (remap(little_cumulative_angle,0.0,180.0,0.0,1.0))
	thumb_closedness = (remap(thumb_cumulative_angle,0.0,100.0,0.0,1.0))
	#check whether hand tracking data is available for the first time 
	#	if it is, then setup the hand
	if XRServer.primary_interface is OpenXRInterface and get_child_count(true)==0:
		interface = XRServer.primary_interface
		if interface.is_hand_tracking_supported():
			setup_hand()
	for child:Node3D in get_children():
		if "target" in child:
			var num:int=child.name.to_int()
			if interface.get_hand_joint_flags(hand,num) != 0:
				child.target = interface.get_hand_joint_position(hand,num)
				child.quaternion = interface.get_hand_joint_rotation(hand,num)
				joint_positions[num] = child.target
				joint_rotations[num] = child.rotation_degrees
				if num == 0:
					child.find_child("label",true,false).text = "index: {0}\nmiddle: {1}\nring: {2}\nlittle: {3}\nthumb: {4}".format([
						index_closedness,
						middle_closedness,
						ring_closedness,
						little_closedness,
						thumb_closedness])
					if abs(joint_rotations[num].z) > 135.0 and index_cumulative_angle > 90.0:
						child.visible = true
					elif child.visible and abs(joint_rotations[num].z) < 100.0:
						child.visible = false
			#else:
				#child.hide()

## setup the hand procedurally based on the 26 known hand joints
func setup_hand():
	for i in range(26):
		#instantiate a tracker to place at this joint
		var tmp:Node3D = load("res://tracker.tscn").instantiate()
		var tmp:Node3D = load("res://tracker.tscn").instantiate()
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
			#palm joint
			#palm joint
			0:
				var label:Label3D = Label3D.new()
				label.text = "TEST"
				label.name = "label"
				tmp.add_child(label)
				label.position.y = -.1
				label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
				label.fixed_size = true
				label.font_size = 2
				print(label)
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

func index_finger()->float:
	var finger := (
		joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL].distance_to(
			joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE]
		)
		)
		#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_DISTAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_DISTAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_INDEX_TIP]
		#)
	#)/4.0
	if finger < finger_activation_distance and !index_pointing:
		index_pointing = true
	elif finger > finger_activation_distance and index_pointing:
		play_sound()
		index_pointing = false
	return finger

func middle_finger()->float:
	var finger := (
		joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL].distance_to(
			joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_INTERMEDIATE]
		)
		)
		#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_INTERMEDIATE]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_INTERMEDIATE].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_DISTAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_DISTAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_MIDDLE_TIP]
		#)
	#)/4.0
	if finger < finger_activation_distance and !middle_pointing:
		middle_pointing = true
	elif finger > finger_activation_distance and middle_pointing:
		play_sound(.9)
		middle_pointing = false
	return finger

func ring_finger()->float:
	var finger := (
		joint_rotations[OpenXRInterface.HAND_JOINT_RING_METACARPAL].distance_to(
			joint_rotations[OpenXRInterface.HAND_JOINT_RING_INTERMEDIATE]
		)
		)
		#joint_rotations[OpenXRInterface.HAND_JOINT_RING_METACARPAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_RING_PROXIMAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_RING_PROXIMAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_RING_INTERMEDIATE]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_RING_INTERMEDIATE].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_RING_DISTAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_RING_DISTAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_RING_TIP]
		#)
	#)/4.0
	if finger < finger_activation_distance and !ring_pointing:
		ring_pointing = true
	elif finger > finger_activation_distance and ring_pointing:
		play_sound(.8)
		ring_pointing = false
	return finger

func little_finger()->float:
	var finger := (
		joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL].distance_to(
			joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE]
		)
		)
		#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_DISTAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_DISTAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_LITTLE_TIP]
		#)
	#)/4.0
	if finger < finger_activation_distance and !little_pointing:
		little_pointing = true
	elif finger > finger_activation_distance and little_pointing:
		play_sound(.7)
		little_pointing = false
	return finger

func thumb_finger()->float:
	var finger := (
		joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_METACARPAL].distance_to(
			joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_DISTAL]
		)
		#joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_METACARPAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_PROXIMAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_PROXIMAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_DISTAL]
		#)+
		#joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_DISTAL].distance_to(
			#joint_rotations[OpenXRInterface.HAND_JOINT_THUMB_TIP]
		#)
	)
	#)/4.0
	if finger < finger_activation_distance and !thumb_pointing:
		thumb_pointing = true
	elif finger > finger_activation_distance and thumb_pointing:
		play_sound(.6)
		thumb_pointing = false
	return finger

func play_sound(pitch_scale:float=1.0):
	var tmpaudio = AudioStreamPlayer3D.new()
	tmpaudio.stream = ui_boop
	tmpaudio.pitch_scale=pitch_scale
	add_child(tmpaudio)
	tmpaudio.finished.connect(tmpaudio.queue_free)
	tmpaudio.play()
