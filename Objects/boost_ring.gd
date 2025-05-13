@tool #this makes it so code can run in the editor
extends Area3D

@onready var particles = $ring/CPUParticles3D

@export_range(5, 40, 0.1, "or_greater") var strength : float = 10
@export var centerPlayer : bool = false ##Forces the player to get centered when precision is needed
@export var rotating : bool = false #new rotation option
@export var rotationSpeed : float = 1.0


var strengthLastFrame = strength


func _process(_delta: float) -> void:
	$ring.rotation.x += 0.02
	$direction.scale.x = strength
	if !Engine.is_editor_hint(): #hide the helper arrow in game
		$direction.visible = false
	
	#I have to do this stupidness because the particles reset every time the Amount value is changed
	#So if I change it every frame it'll constantly reset and nothing will spawn
	if strengthLastFrame != strength:
		particles.amount = int(strength) * 2
	strengthLastFrame = strength
	
	
	particles.initial_velocity_min = strength * 1.5 -1
	particles.initial_velocity_max = strength * 1.5 +1
	particles.linear_accel_min = strength * -1 -1
	particles.linear_accel_max = strength * -1 +1
	
	
	
	if rotating: #checks for rotation value
		rotation_degrees.y += rotationSpeed
	
	


func _on_body_entered(body: Node3D) -> void:
	if body is player:
		
		
		
		if centerPlayer:
			body.global_position = global_position
		
		body.linear_velocity = Vector3(0,0,0)
		body.angular_velocity = Vector3(0,0.1,0)
		
		var distance = %goal.global_position - global_position
		
		distance.y += 1 #slight upward boost to counter gravity
		
		body.apply_torque_impulse(distance)
		body.apply_impulse(distance*3)
		
		ScoreManager.reset_airspin()
		if body.lastUsedBoost != self:
			body.lastUsedBoost = self
			ScoreManager.give_points(500, 1, true, "BOOST")
			ScoreManager.play_trick_sfx("rare")
		#body.play_random_trick()
		
		#sound 
		$BoostSound.play() 
