extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#ZOOM
	var target = $"../.."  # fish shortcut
	var direction = (target.global_transform.origin - global_transform.origin).normalized()
	var move_amount = 0.5  # zoom speed
	var current_distance = global_transform.origin.distance_to(target.global_transform.origin)
	
	if Input.is_action_just_pressed("zoom in"):
		if current_distance > 1.0:
			global_transform.origin += direction * move_amount
	
	if Input.is_action_just_pressed("zoom out"):
		if current_distance < 10.0:
			global_transform.origin -= direction * move_amount
		
		
		
		
		
		#fov = clamp(fov + 5, 30, 110)
		
