extends Area3D

var coolDown = 0
var stopSlowmo
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
		Engine.time_scale = clamp(distance-0.1, 0.1, 1) #slowmo
		var pitch = AudioServer.get_bus_effect(4,0)
		pitch.pitch_scale = clamp(distance*0.5 +0.4, 0.5, 1) #music slow down
		
		var zoom = 80 - (25 - clamp(distance*25, 0, 25) )
		get_tree().get_first_node_in_group("camera").fov = zoom
		
		print("distance: ", distance, " pitch: ", pitch.pitch_scale)
		
		#sounds
		$SlomoEnd.play()
		
	
	animTimer += 1 #make the string flutter
	for nodes in $hoopString.get_children():
		nodes.rotation_degrees.y = sin(animTimer*0.1) * 5
	
	

## On successful dunking
func _on_body_entered(body: Node3D) -> void:
	if body is enemy:
		ScoreManager.give_points(99999, 0, true, "CRAB DUNK")
	
	if body is player: #and coolDown > 60:
		if body.linear_velocity.y < 0: 
			#coolDown = 0
			
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
			stopSlowmo = true
			Engine.time_scale = 1
			
		else: #anti cheat lol
			print("CHEATER")
	
	body.apply_central_impulse(Vector3(0, -10, 0))
	


func _on_slowmo_body_entered(body: Node3D) -> void:
	if body is player:
		$Slomo.play() #sound for starting slowmo


func _on_slowmo_body_exited(body):
	if body is player:
		Engine.time_scale = 1
		var pitch = AudioServer.get_bus_effect(4,0)
		pitch.pitch_scale = 1


func _on_reset_hoop_body_exited(body):
	%hoopCollision.collision_layer = 1 #reaply collision once fish leaves
	stopSlowmo = false
