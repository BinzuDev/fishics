extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("zoom in"):
		fov = clamp(fov - 5, 30, 100)
	
	if Input.is_action_just_pressed("zoom out"):
		fov = clamp(fov + 5, 30, 100)
