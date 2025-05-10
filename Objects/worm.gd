extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	$wormsprite.rotation.y += 0.09 #rotation
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and visible:
		print("got worm!")
		ScoreManager.give_points(800,5,true, "WORM")
		visible = false
		$WormSFX.play()
