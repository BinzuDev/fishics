class_name CameraController
extends Area3D

##The angle that the fish's "CameraAnchor" node will take
@export var newCameraAngle : Vector3
##Rate of which the camera will turn. 
##A value of 0.5 means that every frame the camera will travel 50% of the remaining way. 
##Use a value of 1.0 for instant transitions
@export_range(0, 1, 0.01) var rate = 0.2

func _ready():
	collision_layer = 8 #layer 4
	collision_mask = 0
