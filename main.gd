extends Node3D

@onready var xr_origin_3d = $XROrigin3D
@onready var world_environment = $WorldEnvironment

func _ready():
	for interface in XRServer.get_interfaces():
		if interface.name == "OpenXR":
			XRServer.get_interface(interface.id).initialize()
			get_viewport().use_xr = true
			if XRServer.get_interface(interface.id) is OpenXRInterface:
				Engine.physics_ticks_per_second = XRServer.get_interface(interface.id).display_refresh_rate
			if XRServer.get_interface(interface.id).is_passthrough_supported():
				get_viewport().transparent_bg = true
				print(XRServer.get_interface(interface.id).start_passthrough())
				world_environment.environment.background_mode = 0

