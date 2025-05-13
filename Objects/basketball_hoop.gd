extends Area3D

var coolDown = 0
var stopSlowmo : bool = false
var animTimer : int = 0


func _physics_process(_delta: float) -> void:
	coolDown += 1
	
	#if $dontResetCombo.has_overlapping_bodies():
		#var fish = $dontResetCombo.get_overlapping_bodies()
		#fish[0].give_points(0,0,true) #resets the timer
		##fish[0].comboTimer += 2 #give you extra time
	#else:
		#%hoopCollision.collision_layer = 1 #reaply collision once fish leaves
		#stopSlowmo = false
	
	 
	if $slowmo.has_overlapping_bodies() and stopSlowmo == false:
		var fish = $slowmo.get_overlapping_bodies()
		var distance = (fish[0].global_position - global_position).length() * 0.5
		Engine.time_scale = clamp(distance-0.15, 0.1, 1) #slowmo
		var pitch = AudioServer.get_bus_effect(4,0)
		pitch.pitch_scale = clamp(distance*0.5 +0.4, 0.5, 1) #music slow down
		
		var zoom = 80 - (25 - clamp(distance*25, 0, 25) )
		get_tree().get_first_node_in_group("camera").fov = zoom
		
		#print("distance: ", distance, " pitch: ", pitch.pitch_scale)
		
		#sounds
		$SlomoEnd.play()
		
	animTimer += 1 #make the string flutter
	for nodes in $hoopString.get_children():
		nodes.rotation_degrees.y = sin(animTimer*0.1) * 5
	
	$Label3D.text = str("stopSlowmo: ", stopSlowmo, "
	slowmo.overlapping: ", $slowmo.has_overlapping_bodies(), "
	resetHoop.overlapping: ", $resetHoop.has_overlapping_bodies(), "
	DunkArea.overlapping: ", self.has_overlapping_bodies(), "
	cooldown: ", coolDown)
	
	

## On successful dunking
func _on_body_entered(body: Node3D) -> void:
	print(body.name, " HAS ENTERED THE DUNKING AREA")
	#get_tree().paused = !get_tree().paused
	
	if body is enemy:
		ScoreManager.give_points(99999, 0, true, "CRAB DUNK")
	
	stopSlowmo = true
	if body is player: 
		#if coolDown < 60:
			#$dunkList.text += str("\nENTERING AGAIN DURING COOLDOWN")
			#print("ENTERING AGAIN DURING COOLDOWN")
		#else:
			#if body.linear_velocity.y >= 0: 
				#print("IN THEORY, THE PLAYER SHOULD BE GOING UPWARDS RN, AND THUS, DUNK DOESNT COUNT")
				#$dunkList.text += str("\nBAD DUNK \n spd: ", body.linear_velocity.y  )
				#print("spd: ", body.linear_velocity.y)
			#else:
				$dunkList.text += str("\nSUCCESSFUL DUNK \n spd: ", body.linear_velocity.y  )
				print("SUCCESSFUL DUNK spd: ", body.linear_velocity.y)
				#Diffrenciates between dunks
				if body.linear_velocity.y < -15:
					if body.diving:
						ScoreManager.give_points(4000, 10, true, "DIVING DUNK")
					else:
						ScoreManager.give_points(8000, 30, true, "KOBE")
					ScoreManager.play_trick_sfx("legendary") 
				elif body.linear_velocity.y < -10:
					ScoreManager.give_points(2000, 10, true, "BIG DUNK")
					ScoreManager.play_trick_sfx("rare")
				else:
					ScoreManager.give_points(1000, 5, true, "SLAM DUNK")
					
				
				ScoreManager.comboTimer += 80 #give you extra time
				
				$ScoreSound.play() #dunk sfx
				$HoopPuff.emitting = true #Particles 
				%hoopCollision.collision_layer = 0 #disable collision so fish passes through
				$antiCheese.collision_layer = 0
				Engine.time_scale = 1
			
	
	print("Applying central impusle to ", body.name)
	body.apply_central_impulse(Vector3(0, -10, 0))
	coolDown = 0
	


func _on_slowmo_body_entered(body: Node3D) -> void:
	print(body.name, " HAS ENTERED THE SLOMO AREA")
	if body is player:
		$Slomo.play() #sound for starting slowmo


func _on_slowmo_body_exited(body):
	print(body.name, " HAS EXITED THE SLOMO AREA")
	if body is player:
		Engine.time_scale = 1
		var pitch = AudioServer.get_bus_effect(4,0)
		pitch.pitch_scale = 1


func _on_reset_hoop_body_exited(body):
	print(body.name, " HAS EXITED THE RESET HOOP AREA")
	%hoopCollision.collision_layer = 1 #reaply collision once fish leaves
	$antiCheese.collision_layer = 4
	stopSlowmo = false
