extends RigidBody3D
#SETTING UP

#NAMING
#@onready var jum_ray_cast = $JumpRayCast #unused, but keep as an example if needed


#MOVEMENT CONSTS
const torque_impulse = Vector3(0, 0, 1.5)  #front-back rotation speed
const torque_side = Vector3(1.5, 0, 0)     #left-right rotation speed
const jump = Vector3(0, 9, 0)              #jump strength                                                      
const accel : float = 1.5                  #acceleration speed

#TIMING VARS
var timeSinceJump : int = 0
var flopTimer : int = 0
var sfxCoolDown : int = 0


func _ready() -> void:
	pass #Code that happens on the first frame the game is loaded



func _physics_process(_delta: float) -> void:
	
	## Movement
	if Input.is_action_just_pressed("forward"):
		apply_torque_impulse(torque_impulse)
		apply_impulse(Vector3(-accel, 0, 0))
	
	if Input.is_action_just_pressed("back"):
		apply_torque_impulse(torque_impulse * -1)
		apply_impulse(Vector3(accel, 0, 0))
	
	if Input.is_action_just_pressed("right"):
		apply_torque_impulse(torque_side * -1)
		apply_impulse(Vector3(0, 0, -accel))
	 
	if Input.is_action_just_pressed("left"):
		apply_torque_impulse(torque_side)
		apply_impulse(Vector3(0, 0, accel))
	
	
	## Jumping
	timeSinceJump += 1
	if Input.is_action_just_pressed("jump"):
		if timeSinceJump > 20 and $floorDetection.is_colliding():
			timeSinceJump = 0
			
			#audio
			####
			$Jumps.play()
			$Soft_Impact.play()
			#####
			
			apply_impulse(jump)
			apply_torque_impulse(torque_impulse)
			#jump Particle
			$JumpPuff.emitting = true
			$JumpPuff.restart()
			
			#mid Air extra control
			#####
			if Input.is_action_pressed("forward"):
				apply_torque_impulse(torque_impulse)
				apply_impulse(Vector3(-accel * 3, 0, 0)) #extra acceleration
				
			if Input.is_action_pressed("back"):
				apply_torque_impulse(torque_impulse * -2) #-2 so it actually flips backwards
				apply_impulse(Vector3(accel * 3, 0, 0))
				
			if Input.is_action_pressed("right"):
				apply_torque_impulse(torque_side * -1)
				apply_impulse(Vector3(0, 0, -accel * 3))
				 
			if Input.is_action_pressed("left"):
				apply_torque_impulse(torque_side)
				apply_impulse(Vector3(0, 0, accel * 3))
			#####
			
	
	
	## Flop Animation
	var amp = max(angular_velocity.length() * 0.18, linear_velocity.length())
	
	flopTimer += 1 
	$pivotUpper.rotation_degrees.z = sin(flopTimer * 0.3) *  3*clamp(amp, 1, 10)
	$pivotLower.rotation_degrees.z = sin(flopTimer * 0.3) * -3*clamp(amp, 1, 10)
	$pivotUpper/pivotHead.rotation_degrees.z = sin(flopTimer * 0.3) *  6*clamp(amp, 1, 10)
	$pivotLower/pivotTail.rotation_degrees.z = sin(flopTimer * 0.3) *  -6*clamp(amp, 1, 10)  
	#print("1: ", $pivotLower/pivotTail.rotation_degrees.z, " 2: ", $pivotLower.rotation_degrees.z, "  3: ",$pivotUpper.rotation_degrees.z, " 4:", $pivotUpper/pivotHead.rotation_degrees.z)
	
	## Particle Effects
	if amp >= 3:
		$BubbleRing.emitting = true
	else:
		$BubbleRing.emitting = false
	
	
	## Restart
	if global_position.y < -15:
		get_tree().reload_current_scene()
	
	
	
	## Audio
	#FIsh button
	if Input.is_action_just_pressed("FIsh"):
		$FIsh.play()
	
	#the cooldown gets shorter the faster you are
	sfxCoolDown += clamp(amp, 0, 8) #caps at 8
	
	if get_contact_count() > 0 and sfxCoolDown > 30 and amp >= 0.4:
		sfxCoolDown = 0
		print("contacts: ", get_contact_count())
		
		if amp >= 14:
			$Hard_Impact.pitch_scale = 1
			$Hard_Impact.play()
			print("play hard, pitch: ", $Hard_Impact.pitch_scale, " speed: ", amp )
		elif amp >= 8:                   #from 0.8 to 1.17 at amp 14
			$Medium_Impact.pitch_scale = 0.35 + amp / 15
			$Medium_Impact.play()
			print("play meduim, pitch: ", $Medium_Impact.pitch_scale, " speed: ", amp )
		else:                         #from 0.7 to 1.3 at amp 8
			$Soft_Impact.pitch_scale = 0.7 + amp / 15
			$Soft_Impact.play()
			print("play soft, pitch: ", $Soft_Impact.pitch_scale, " speed: ", amp )
	
	
	## Debug Print
	#print("amp: ", snapped(amp, 0.1), "  contacts: ", get_contact_count(), " cooldown: ", sfxCoolDown  )
	
	
	


func _on_speed_boost_touched(body):
	apply_torque_impulse(torque_side * -20)
	apply_impulse(Vector3(0, 0, -accel * 20))
