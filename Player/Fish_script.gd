class_name player 
extends RigidBody3D


var checkpoint_pos: Vector3 # i like men too teeheehee

#camera
var targetCamAngle: Vector3
var targetCamPos: Vector3
var camSpeed: float = 0.2
var cameraOverride: bool = false

#other trick variables
var tiplanding : bool = false
var isTipSpinning : bool = false
var superJumpTimer : int = -1
var height : float = 0 ##stores how for away you are to the nearest floor
var fishCooldown : int = 0
var diving = false
var lastUsedBoost

#MOVEMENT CONSTS
const torque_impulse = Vector3(-1.5, 0, 0)  #front-back rotation speed
const torque_side = Vector3(0, 0, 1.5)     #left-right rotation speed
const jump = Vector3(0, 9, 0)              #jump strength                                                      
const accel : float = 1.5                  #acceleration speed

#TIMING VARS
var timeSinceJump : int = 0
var flopTimer : int = 0
var sfxCoolDown : int = 0


func _ready() -> void:
	checkpoint_pos = position
	$UI/splashScreen.visible = true
	ScoreManager.fish = self

func _physics_process(_delta: float) -> void:
	#splash screen fadeout
	if flopTimer >= 5: #skip the first couple of frames for lag
		$UI/splashScreen.modulate.a -= 0.05
	
	## Movement
	if Input.is_action_just_pressed("forward"):
		apply_torque_impulse(rotate_by_cam(torque_impulse))
		apply_impulse(rotate_by_cam(Vector3(0, 0, -accel)))
	
	if Input.is_action_just_pressed("back"):
		apply_torque_impulse(rotate_by_cam(torque_impulse * -1))
		apply_impulse(rotate_by_cam(Vector3(0, 0, accel)))
	
	if Input.is_action_just_pressed("right"):
		apply_torque_impulse(rotate_by_cam(torque_side * -1))
		apply_impulse(rotate_by_cam(Vector3(accel, 0, 0)))
	 
	if Input.is_action_just_pressed("left"):
		apply_torque_impulse(rotate_by_cam(torque_side))
		apply_impulse(rotate_by_cam(Vector3(-accel, 0, 0)))
	
	
		###############
		##  Jumping  ##
	timeSinceJump += 1
	if Input.is_action_just_pressed("jump"):
		if timeSinceJump > 20 and $floorDetection.is_colliding():
			timeSinceJump = 0
			#audio
			$Jumps.play()
			$Soft_Impact.play() 
			
			#jump Particle
			$JumpPuff.restart()
			$JumpPuff.emitting = true
			
			#mid Air extra control
			var pressingKey = false
			var boost = (accel * 3) + clamp(angular_velocity.length()*0.1, 0, 12)
			
			if Input.is_action_pressed("forward"):
				apply_torque_impulse(rotate_by_cam(torque_impulse))
				apply_impulse(rotate_by_cam(Vector3(0, 0, -boost))) #extra acceleration
				pressingKey = true
			if Input.is_action_pressed("back"):
				apply_torque_impulse(rotate_by_cam(torque_impulse * -2)) #-2 so it actually flips backwards
				apply_impulse(rotate_by_cam(Vector3(0, 0, boost)))
				pressingKey = true
			if Input.is_action_pressed("right"):
				apply_torque_impulse(rotate_by_cam(torque_side * -1))
				apply_impulse(rotate_by_cam(Vector3(boost, 0, 0)))
				pressingKey = true
			if Input.is_action_pressed("left"):
				apply_torque_impulse(rotate_by_cam(torque_side))
				apply_impulse(rotate_by_cam(Vector3(-boost, 0, 0)))
				pressingKey = true
			
			#apply vertical speed
			apply_impulse(jump)
			apply_torque_impulse(rotate_by_cam(torque_impulse)) #flop forward
			
			
			## Style Meter and jump related tricks
			superJumpTimer = 5 #check your speed 5 frames after jumping
			
			if is_in_air() and $nearFloor.is_colliding():
				ScoreManager.give_points(1000,0, true, "POGO JUMP", "uncommon")
				#play_trick_sfx("uncommon")
			
			if !$nearFloor.is_colliding():
				ScoreManager.give_points(800,1, true, "WALL JUMP", "uncommon")
				ScoreManager.reset_airspin()
				#play_trick_sfx("uncommon")
			
			if not pressingKey: #High Jump
				var xtraYspd = clamp(angular_velocity.length()*0.3, 0, 30)
				
				apply_impulse(rotate_by_cam(Vector3(0, xtraYspd, 0)))
				#print("HIGH JUMP, speed: ", linear_velocity.length())
				
				if linear_velocity.length() > 12: #Points
					ScoreManager.give_points(500, 1, true, "HIGH JUMP", "uncommon")
					#play_trick_sfx("uncommon")
			else:
				var hspeed = linear_velocity #get your speed
				hspeed.y = 0  #remove your vertical speed from the equation
				hspeed = hspeed.length() #get your true horziontal speed 
				#print("LONG JUMP, speed: ", hspeed)
				if linear_velocity.length() > 12:
					ScoreManager.give_points(200, 1, true, "LONG JUMP", "uncommon")
					#play_trick_sfx("uncommon")
				
	
	## Super Jump tricks
	if superJumpTimer >= 0:
		superJumpTimer -= 1
	if superJumpTimer == 0:
		#print("super jump:  v: ", linear_velocity.y)
		if linear_velocity.y > 25:
			ScoreManager.give_points(5000, 5, true, "VERTICAL JUMP")
			ScoreManager.comboTimer += 80 #give you extra time
			ScoreManager.play_trick_sfx("legendary")
		
	
	
	## Diving
	if $heightDetect.is_colliding():
		height = global_position.y - $heightDetect.get_collision_point().y
		
	if Input.is_action_just_pressed("dive"):
		var newSpd = clamp(height*-1.5 -10, -75, -10) 
		linear_velocity.y = min(newSpd, linear_velocity.y)
		print("height: ", height, " speed: ", newSpd, " points: ", 100*height )
		ScoreManager.give_points(100*height, 0, false, "DIVE")
		if height > 10:
			ScoreManager.give_points(0, 0, true) #only reset the timer if you're high up enough
			ScoreManager.play_trick_sfx("rare")
		if newSpd == -75:
			ScoreManager.give_points(0, 10, true, "HIGH DIVE") #diving at capped height
			ScoreManager.play_trick_sfx("legendary")
		
		diving = true #DIVING VARIABLE
	
	if get_contact_count() >= 1:
		diving = false
		
	
	## Flop Animation
	var amp = max(angular_velocity.length() * 0.18, linear_velocity.length())
	flopTimer += 1 
	$pivotUpper.rotation_degrees.z = sin(flopTimer * 0.3) *  3*clamp(amp, 1, 10)
	$pivotLower.rotation_degrees.z = sin(flopTimer * 0.3) * -3*clamp(amp, 1, 10)
	$pivotUpper/pivotHead.rotation_degrees.z = sin(flopTimer * 0.3) *  6*clamp(amp, 1, 10)
	$pivotLower/pivotTail.rotation_degrees.z = sin(flopTimer * 0.3) *  -6*clamp(amp, 1, 10)  
	
	
	## Particle Effects
	if amp >= 3:
		$BubbleRing.emitting = true
	else:
		$BubbleRing.emitting = false
	
	
	## Restart
	if global_position.y < -15:
		ScoreManager.end_combo() #reset combo
		#get_tree().reload_current_scene()
		position = checkpoint_pos
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		
	
	## Camera
	#fov
	%cam.fov = lerp(%cam.fov, 80.0, 0.1)   
	if %cam.fov > 79.99:
		%cam.fov = 80
	#camera controller areas
	if $detectCamSwitch.has_overlapping_areas():
		var area = $detectCamSwitch.get_overlapping_areas()[0]
		targetCamAngle = area.newCameraAngle
		camSpeed = area.rate
		cameraOverride = true #so you cant move the cam manually in switch areas
	elif cameraOverride == false:
		targetCamAngle = Vector3(0,0,0) #default camera settings
		targetCamPos  = Vector3(0,0,0)
		camSpeed = 0.2
	
	#Manual camera control
	if Input.is_action_pressed("camera") and !cameraOverride:
		if Input.is_action_pressed("right"): 
			targetCamAngle.y -= 30
			targetCamPos = Vector3(2.5, 0, 0.6)
			cameraOverride = true
		elif Input.is_action_pressed("left"):
			targetCamAngle.y += 30
			targetCamPos = Vector3(-2.5, 0, 0.6)
			cameraOverride = true
		elif Input.is_action_pressed("forward"):
			targetCamAngle.x += 40
			targetCamPos = Vector3(0, 2.3, -1.5)
			cameraOverride = true
		elif Input.is_action_pressed("back"):
			targetCamAngle.x -= 15
			targetCamPos = Vector3(0,-0.7,3.5)
			cameraOverride = true
	
	if !Input.is_action_pressed("camera"): #reset camera when you let go of C
		cameraOverride = false
	
	%camMove.rotation_degrees = %camMove.rotation_degrees.lerp(targetCamAngle, camSpeed) 
	%camMove.position = %camMove.position.lerp(targetCamPos, camSpeed)
	
	
	
	## Audio (flopping sfx) ##
	#the cooldown gets shorter the faster you are
	sfxCoolDown += clamp(amp, 0, 8) #caps at 8
	
	if get_contact_count() > 0 and sfxCoolDown > 30 and amp >= 0.4:
		sfxCoolDown = 0
		
		if amp >= 14:
			$Hard_Impact.pitch_scale = 1
			$Hard_Impact.play()
			#print("play hard, pitch: ", $Hard_Impact.pitch_scale, " speed: ", amp )
			$JumpPuff.restart() #harsh particles
			$JumpPuff.emitting = true
		elif amp >= 8:                   #from 0.8 to 1.17 at amp 14
			$Medium_Impact.pitch_scale = 0.35 + amp / 15
			$Medium_Impact.play()
			#print("play meduim, pitch: ", $Medium_Impact.pitch_scale, " speed: ", amp )
		else:                         #from 0.7 to 1.3 at amp 8
			$Soft_Impact.pitch_scale = 0.7 + amp / 15
			$Soft_Impact.play()
			#print("play soft, pitch: ", $Soft_Impact.pitch_scale, " speed: ", amp )
	
	
	  
	  
	###################
	##  STYLE METER  ##
	################### 
	
	
	## Hangtime
	if is_in_air() and !$nearFloor.is_colliding(): 
		ScoreManager.give_points(clamp(height, 1, 10), 0, false, "HANGTIME")
	
	## SPEEN
	if angular_velocity.length() > 100:
		ScoreManager.give_points(angular_velocity.length()*0.05,0,false, "SPEEN")
	
	
	
	## Tipspin
	isTipSpinning = false
	if get_side_count() == 1 and ($trickRC/tail.is_colliding() or $trickRC/head.is_colliding()):
		if linear_velocity.length() > 0.5 and angular_velocity.length() > 10:
			isTipSpinning = true
			ScoreManager.give_points(500/linear_velocity.length()*2, 0, true, "TIPSPIN")
			if ScoreManager.mult == 0: #in case you do a tipspin without a combo first
				ScoreManager.give_points(0, 1, true, "")
		
		## Tip landing
		if !tiplanding and linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
			tiplanding = true
			ScoreManager.give_points(999999, 200, true, "TIPLANDING HOLY SHIT")
			ScoreManager.change_rank(8, 1.0)
			ScoreManager.comboTimer += 500
			ScoreManager.play_trick_sfx("legendary")
	
	if is_in_air():
		tiplanding = false #reset tiplanding is the air so you can do it again
	
	if linear_velocity.length() < 0.1 and !tiplanding:
		ScoreManager.idle = true
	else:
		ScoreManager.idle = false
	
	
	
	## Fish button
	$pivotUpper.visible = true
	$pivotLower.visible = true
	$posing.visible = false
	$flash.visible = false
	$dead_fish.modulate.a -= 0.05
	$dead_fish.scale -= Vector2(0.01, 0.01)
	fishCooldown += 1
	if Input.is_action_just_pressed("FIsh"):
		$FIsh.play()
		if height > 8 and abs(linear_velocity.y) < 5 and fishCooldown > 60:
			global.freezeframe = 20
			get_tree().paused = true
			ScoreManager.give_points(height*500, 5, true, "POSE FOR THE CAMERA")
			$taunt.play()
			$pivotUpper.visible = false
			$pivotLower.visible = false
			$posing.visible = true
			$flash.visible = true
			$tauntAnimation.play("taunt")
		else:
			ScoreManager.give_points(100, 0, false, "FISH!")
			$dead_fish.visible = true
			$dead_fish.modulate.a = 1
			$dead_fish.scale = Vector2(1.2, 1.2)
		fishCooldown = 0
	
	
	## AIR SPIN
	var deg_vel = angular_velocity.length() #get rotation speed
	deg_vel = rad_to_deg(deg_vel) / 60 #transform radians per second into degrees per frame 
	
	ScoreManager.airSpinAmount += deg_vel
	
	#reset when touching the floor
	if get_contact_count() > 0 and $nearFloor.is_colliding(): 
		ScoreManager.reset_airspin()
	
	
	
	#DEBUG_INFO
	%debugLabel.text = str(
	"fov: ", %cam.fov, "\n",
	"height: ", height, "\n",
	"linear velocity: ", linear_velocity.length(), "\n",
	"angular velocity: ", angular_velocity, "\n",
	"angular length: ", angular_velocity.length(), "\n",
	)
	


## This functions takes in a vector, and rotates it so that forward points
## towards where the camera is looking
func rotate_by_cam(vector : Vector3):
	return vector.rotated(Vector3(0,1,0), %camMove.rotation.y)

##Temporarily change the FOV of the camera for a zoom-in impact effect
func set_fov(newFov:float):
	%cam.fov = newFov

func get_side_count():
	var count = 0
	for raycast in $trickRC.get_children():
		if raycast.is_colliding():
			count += 1
	return count

## Returns true when there is 0 physical contacts
func is_in_air(): 
	if get_contact_count() == 0:
		return true
	else:
		return false
		

func set_skin(): #doesnt work yet
	var skin = preload("res://Skins/binzufish.png")
	$pivotUpper/upperBody.texture = skin
	$pivotUpper/pivotHead/head.texture = skin
	$pivotLower/lowerBody.texture = skin
	$pivotLower/pivotTail/tail.texture = skin
	
