extends Node3D

@onready var xr_origin_3d = $XROrigin3D
@onready var world_environment = $WorldEnvironment

func _ready():
	init_xr()
	# testing for detecting trackers
	XRServer.tracker_added.connect(func(tracker_name:String,type:int):
		print('tracker added')
		print(tracker_name)
		)

func init_xr():
	# iterate over all the found XR interfaces
	for interface in XRServer.get_interfaces():
		# if the "OpenXR" interface is found, begin initializing it
		if interface.name == "OpenXR":
			XRServer.get_interface(interface.id).initialize()
			# tell the viewport to be designated to rendering for the XR device
			get_viewport().use_xr = true
			# Set the engine physics tick rate to be the same as the headset 
			#	refresh rate to keep the physics in sync with the device data
			Engine.physics_ticks_per_second = XRServer.get_interface(interface.id).display_refresh_rate
			# check to see if passthrough is supported
			if XRServer.get_interface(interface.id).is_passthrough_supported():
				# if it is, then we set the viewport to be transparent
				get_viewport().transparent_bg = true
				# start passthrough
				print(XRServer.get_interface(interface.id).start_passthrough())
				# set the world environment background to clear color
				#	so that it doesn't blend the sky shader with the passthrough
				world_environment.environment.background_mode = 0

