extends Sprite3D

var timer = 0
var min_scale = 0.7
var max_scale = 0.8
var speed = 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta * speed
	var scale_value = min_scale + (max_scale - min_scale) * (sin(timer) + 1) / 2
	scale = Vector3(scale_value, scale_value, scale_value)
	
	
	
	
	
	#for body in $RaveArea.get_overlapping_bodies():
		#if "agro" in body and not body.agro:
			#body.animation_crab.play("RAVE")

	
	


func _on_rave_area_body_entered(body: Node3D) -> void:
	#RAVE
	if body is enemy and not body.agro and body.hp > 0:
		body.animation_crab.play("RAVE")




func _on_rave_area_body_exited(body: Node3D) -> void:
	if body is enemy and not body.agro:
		body.animation_crab.play("RESET")
