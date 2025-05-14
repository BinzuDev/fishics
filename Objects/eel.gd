extends Sprite3D
var initalPos = 0
var rising := false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initalPos = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#rising and lowering code
	if rising and position.y < 24:
		position.y += 0.1
	
	if rising == false and position.y > initalPos:
		position.y -= 0.1


func _on_area_eel_body_entered(body: Node3D) -> void:
	if body is player:
		rising = true
		print("eel")


func _on_area_eel_body_exited(body: Node3D) -> void:
	rising = false
	print("bye eel")
