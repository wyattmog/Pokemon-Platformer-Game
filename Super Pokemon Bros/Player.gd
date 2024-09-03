class_name Player
extends CharacterBody2D
@onready var audio_player = get_node("SoundEffects")
@onready var powerup_player = get_node("Powerup")
var jump_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/jump.wav")
var spin_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/spin.wav")
var powerup_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/powerup.wav")
var powerdown_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/pipe.wav")
var projectile = preload("res://sounds/SNES - Super Mario World - Sound Effects/fireball.wav")
var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/smw_lost_a_life.wav")
var grass_particle = preload("res://grass_particles.tscn")
var fireball = preload("res://fireball.tscn")
var waterball = preload("res://waterball.tscn")
const SPEED = 225.00
const JUMP_VELOCITY = -250.0
const FRICTION = 35
const ACCELERATION = 5.0
const MARGIN_CHANGE_SPEED = 10.0
var platVel = Vector2(0,0)
var disable_input = false
var plat_vel = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
var DustScene = preload("res://dust.tscn")
var KickScene = preload("res://kick.tscn")
var animplaying = false
var jumptype = ""
var last_pressed = 0
var changeddirection = false
var skid = false
var curr_pos = 0
var bounce = false
#var attack = ""
var scaleup = false
var scaledown = false
var move = true
var camera_moving = false
signal grass_attack
signal grass_attack_ended
signal invincibility
var target_left_margin = 0.0
var target_right_margin = 0.0
var target_top_margin = 0.0
var target_bottom_margin = 0.0
signal jumped
signal landed
var min = 0
var scaled = false
var scaling = false
var direction
var played = false 
var collected = "small"
func _ready():
	#print(get_node("Camera2D").get_drag_margin(1), " and ", get_node("Camera2D").get_drag_margin(3))
	add_to_group("player")
	GameState.player = self
	GameState.display_power()
	get_node("GrassAttack/CollisionShapeRight").disabled = true
	get_node("GrassAttack/CollisionShapeLeft").disabled = true
	scale = Vector2(.90,.90)
	
func emit_signal_while_playing(direction):
	while anim.is_playing():
		if get_node("GrassTimer").is_stopped():
			_spawn_particles()
		anim.set_speed_scale(1)
		get_tree().call_group("enemies", "_on_player_grass_attack")
		get_tree().call_group("enemy_projectiles", "_on_player_grass_attack")
		get_tree().call_group("question_block", "_grass_attack")
		#emit_signal("grass_attack")
		if velocity.x - 50 == min and animplaying and GameState.power == "grass" and abs(velocity.x) > 50:
			#print(velocity.x)
			velocity.x = move_toward(velocity.x, velocity.x - 50, 50)
		elif velocity.x +50 == min and animplaying and GameState.power == "grass" and abs(velocity.x) > 50:
			#print(velocity.x)
			velocity.x = move_toward(velocity.x, velocity.x + 50, 50)
		await get_tree().create_timer(0.0).timeout
	animplaying = false
	get_tree().call_group("enemies", "_on_player_grass_attack_ended")
	if last_pressed == -1:
		get_node("GrassAttack/CollisionShapeLeft").disabled = true
	elif last_pressed == 1:
		get_node("GrassAttack/CollisionShapeRight").disabled = true
	#get_tree().call_group("enemies", "_on_player_grass_attack_ended")
	#get_tree().call_group("question_block", "_grass_attack")
	#emit_signal("grass_attack_ended")
func _physics_process(delta):
	
	#print(GameState.score)
	print("player vel ", velocity.y)
	#print(target_bottom_margin, target_top_margin)
	#print(GameState.big_num_coins)
	#if velocity.y >= 0 and not is_on_floor():
		##get_node("CameraTimer").start()
		#target_bottom_margin = 0.00
		#target_top_margin = 1.00
	if not is_on_floor() and !disable_input:
		#print("wpw")
		#get_node("CameraTimer").start()
		
		target_top_margin = 1.00
		target_bottom_margin = .00
		#get_node("Camera2D").set_drag_vertical_enabled(0)
	elif is_on_floor() and !platVel:
		#get_node("CameraTimer").start()
		target_bottom_margin =1.00
		#get_node("Camera2D").set_drag_vertical_enabled(1)
		target_top_margin = .00
	#if get_node("CameraTimer").is_stopped():
	get_node("Camera2D").drag_bottom_margin = lerp(get_node("Camera2D").drag_bottom_margin, target_bottom_margin, MARGIN_CHANGE_SPEED * .5 *delta)
	get_node("Camera2D").drag_top_margin = lerp(get_node("Camera2D").drag_top_margin, target_top_margin, MARGIN_CHANGE_SPEED * .5 * delta)
	#if Input.is_action_just_pressed("GodMode"):
		#get_tree().call_group("enemies", "invincible_start")
		#get_tree().call_group("enemy_projectiles", "invincible_start")
	#print(disable_input)
	#print(velocity.y)
	#print("player: ", position)
	#print(GameState.projectile_adjustment)
	#print(anim.get_speed_scale())
	#print("plat ",platVel.x,"player " ,velocity.x)
	if not scaling:
		_gravity(delta)
	if !disable_input:
		if not get_node("Invincibility").is_stopped() and played:
			#emit_signal("invincibility")
			#add_to_group("invincibility")
			get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, randi_range(.8,1)))
		elif get_node("Invincibility").is_stopped() and played:
			#get_tree().call_group("enemies", "invincible_end")
			#get_tree().call_group("enemy_projectiles", "invincible_end")
			GameState.invincible = false
			get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
			played = false
		#if GameState.big:
			#scale = Vector2(1.1,1.1)
		#else:
			#scale = Vector2(.9,.9)
		#print("power:",GameState.power,"collect:" ,collected, "big:", GameState.big)
		if scaling:
			scaling = false
			anim.stop(false)
			#move = false
			#var curr_vel = velocity
			#print(curr_vel)
			#velocity = Vector2(0,0)
			#scaler()
			set_physics_process(false)

			#get_node
			if not scaled:
				#print('wpwpwwww')
				#anim.play("Celebration")
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.10,1.10)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.10,1.10)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.1,1.1)
				played = true
			elif scaled and (collected == "grass" or collected == "fire" or collected == "water"):
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				#set_self_modulate(Color(1, 1, 1, .5))
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.1,1.1)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.1,1.1)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				played = true
			elif scaled and (collected != "grass" or collected != "fire" or collected != "water"):
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				#set_self_modulate(Color(1, 1, 1, .5))
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.1,1.1)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.0,1.0)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(1.1,1.1)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				await get_tree().create_timer(.05).timeout
				GameState.big = true
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, .8))
				scale = Vector2(1.00,1.00)
				await get_tree().create_timer(.05).timeout
				GameState.big = false
				get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
				scale = Vector2(.90,.90)
				played = true
			#get_tree().call_group("enemies", "invincible_start")
			#get_tree().call_group("enemy_projectiles", "invincible_start")
			anim.play()
			set_physics_process(true)
			if scaled:
				position.y -= 2

			#move = true
			#scaling = false
		else:
			get_node("AnimatedSprite2D").set_visible(1)
		#if GameState.power = ""
		if GameState.power == "grass" and collected != "grass":
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scaled = false
			#print("grass")
			scale = Vector2(1.1,1.1)
			collected = "grass"
			scaling = true
			#collected = true
			await get_tree().create_timer(.40).timeout
			#collected = "grass"
			scaled = true
		elif GameState.power == "water" and collected != "water":
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scaled = false
			#print("grass")
			scale = Vector2(1.1,1.1)
			collected = "water"
			scaling = true
			#collected = true
			await get_tree().create_timer(.40).timeout
			#collected = "grass"
			scaled = true
		elif GameState.power == "fire" and collected != "fire":
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scaled = false
			#print("grass")
			scale = Vector2(1.1,1.1)
			collected = "fire"
			scaling = true
			#collected = true
			await get_tree().create_timer(.40).timeout
			#collected = "grass"
			scaled = true
		elif GameState.power == "" and GameState.big and (collected == "fire" or collected == "water" or collected == "grass"):
			GameState.display_power()
			audio_player.set_stream(powerdown_sound)
			audio_player.play()
			GameState.invincible = true
			scaled = false
			#print("wow")
			#GameState.power == "big
			collected = "big"
			scaling = true
			get_node("Invincibility").start()
			await get_tree().create_timer(.40).timeout
			scaled = true
		elif GameState.big and not scaled:
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scale = Vector2(1.1,1.1)
			collected = "big"
			scaling = true
			
			await get_tree().create_timer(.40).timeout
			scaled = true
		#elif GameState.big and GameState.power != "":
		elif !GameState.big and scaled:
			GameState.display_power()
			GameState.invincible = true
			audio_player.set_stream(powerdown_sound)
			audio_player.play()
			scale = Vector2(.90,.90)
			collected = "small"
			#GameState.power == "small"
			scaling = true
			get_node("Invincibility").start()
			await get_tree().create_timer(.40).timeout
			scaled = false
		#elif:
			#GameState.big = false
			#scale = Vector2(.95,.95)
		#print(not is_on_floor, jumptype == "spin", GameState.power == "grass")
		if not is_on_floor() and jumptype == "spin" and GameState.power == "grass":
			get_tree().call_group("enemies", "_on_player_grass_attack")
			get_tree().call_group("enemy_projectiles", "_on_player_grass_attack")
			get_tree().call_group("question_block", "_grass_attack")
			if get_node("GrassTimer").is_stopped():
				_spawn_particles()
		direction = Input.get_axis("ui_left", "ui_right")
		if Input.is_action_just_pressed("attack") and !animplaying and GameState.power != "":	
				#print("wow")
				if GameState.power == "grass":
					if last_pressed == -1:
						get_node("GrassAttack/CollisionShapeLeft").disabled = false
					elif last_pressed == 1:
						get_node("GrassAttack/CollisionShapeRight").disabled = false
					#attack = "grass"
					animplaying = true
					powerup_player.set_stream(spin_sound)
					powerup_player.play()
					anim.play("GrassAttack")
					if velocity.x > 0:
						min = velocity.x-50
					else:
						min = velocity.x+50
					emit_signal_while_playing(direction)
				elif GameState.power == "fire":
					animplaying = true
					powerup_player.set_stream(projectile)
					powerup_player.play()
					if velocity.x == 0:
						anim.play("FireIdleAttack")
					elif abs(velocity.x) > 225:
						anim.play("FireRunAttack")
					elif abs(velocity.x) <= 225:
						anim.play("FireWalkAttack")
					var fireball1 = fireball.instantiate()
					fireball1.position.x = position.x
					fireball1.position.y = position.y
					add_sibling(fireball1)
					await anim.animation_finished
					animplaying = false
				elif GameState.power == "water":
					animplaying = true
					powerup_player.set_stream(projectile)
					powerup_player.play()
					if velocity.x == 0:
						anim.play("WaterIdleAttack")
					elif abs(velocity.x) > 225:
						anim.play("WaterRunAttack")
					elif abs(velocity.x) <= 225:
						anim.play("WaterWalkAttack")
					var waterball = waterball.instantiate()
					waterball.position.x = position.x
					waterball.position.y = position.y
					add_sibling(waterball)
					await anim.animation_finished
					animplaying = false
		get_node("Camera2D").position.x = get_node("AnimatedSprite2D").position.x
		get_node("Camera2D").position.y = 0
		# Add the gravity.
		#print(GameState.split)
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			audio_player.set_stream(jump_sound)
			audio_player.play()
			if abs(platVel.x) > 20:
				plat_vel = true
			else:
				plat_vel = false
			_jumped()
			#if !velocity.x:
				#velocity.x += platVel.x
				#get_node("AirResistanceTimer").start()
			#if velocity.x >= 250 or velocity.x <= -250:
				#velocity.y = JUMP_VELOCITY - 50
			#else:
				#velocity.y = JUMP_VELOCITY
			#if !animplaying:
				#animplaying = true
				#if GameState.big:
					#anim.play("BigJump")
				#else:
					#anim.play("SmallJump")
				#animplaying = false
				#jumptype = "jump"
			#if direction == -1:
				#last_pressed = -1
			#elif direction == 1: 
				#last_pressed = 1
				
		if Input.is_action_just_pressed("spinjump") and is_on_floor():
			audio_player.set_stream(spin_sound)
			audio_player.play()
			if abs(platVel.x) > 20:
				plat_vel = true
			else:
				plat_vel = false
			_spinned()
			#if !velocity.x:
				#velocity.x += platVel.x
				#get_node("AirResistanceTimer").start()
			#if velocity.x >= 
			 #or velocity.x <= -250:
				#velocity.y = JUMP_VELOCITY -25
			#else:
				#velocity.y = JUMP_VELOCITY + 25
			#if !animplaying:
				#animplaying = true
				#if GameState.big:
					#anim.play("BigSpin")
				#else: 
					#anim.play("SmallSpin")
				#jumptype = "spin"
				#await not is_on_floor()
				#animplaying = false
			#if direction == -1:
				#last_pressed = -1
			#elif direction == 1: 
				#last_pressed = 1
				
		#if (!Input.is_action_pressed("spinjump") and !Input.is_action_pressed("ui_accept")) and velocity.y < 0:
			#velocity.y += gravity*delta
		if !Input.is_action_pressed("down") and is_on_floor() and !GameState.big:
				get_node("AnimatedSprite2D").offset.y = 0
		if Input.is_action_just_pressed("down") and velocity.x:
				get_node("AnimatedSprite2D").offset.y = 3
		if last_pressed == -1:
			GameState.direct = -1
			get_node("AnimatedSprite2D").flip_h = true
		elif last_pressed == 1:
			GameState.direct = 1
			get_node("AnimatedSprite2D").flip_h = false
		#print(animplaying)
		#print(anim.get_speed_scale())
		if abs(velocity.x) >= 30 and velocity.x:
			if is_on_floor():
				anim.set_speed_scale(abs(velocity.x)/100)
			else:
				anim.set_speed_scale(1)
		else:
			anim.set_speed_scale(1)
		if direction:
			if get_node("AnimatedSprite2D").global_position[0] > 30 + get_node("Camera2D").get_screen_center_position()[0]:

				target_right_margin = 0.0
			elif get_node("AnimatedSprite2D").global_position[0] < get_node("Camera2D").get_screen_center_position()[0] - 30:
				target_left_margin = 0.0
			_directionalMovement(direction)
			if direction < 0:
				last_pressed = -1
			else: 
				last_pressed = 1
		else:
			_directionalMovement(direction)
			if last_pressed == 1:
				target_left_margin = 0.3
			elif last_pressed == -1:
				target_right_margin = 0.3
		if velocity.y > 0 and !animplaying and jumptype=="jump":
			if GameState.power == "grass":
				anim.play("GrassFall")
			elif GameState.power == "fire":
				anim.play("FireFall")
			elif GameState.power == "water":
				anim.play("WaterFall")
			elif GameState.big:
				anim.play("BigFall")
			else:
				anim.play("SmallFall")
		get_node("Camera2D").drag_left_margin = lerp(get_node("Camera2D").drag_left_margin, target_left_margin, MARGIN_CHANGE_SPEED * delta)
		get_node("Camera2D").drag_right_margin = lerp(get_node("Camera2D").drag_right_margin, target_right_margin, MARGIN_CHANGE_SPEED * delta)
	move_and_slide()
	platVel = get_platform_velocity()
func _spawn_kick():
	var new_dust = KickScene.instantiate()
	new_dust.position.x = position.x
	new_dust.position.y = position.y + 14
	add_sibling(new_dust)
func _spawn_particles():
	#if not get_node("FireTimer").is_stopped():
		#return
	var fire_particles = grass_particle.instantiate()
	if anim.get_current_animation() == "GrassAttack":
		if anim.get_current_animation_position() > 0 and anim.get_current_animation_position() < .06:
			fire_particles.position.x = position.x + ((-1*last_pressed) * 15)
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.06 and anim.get_current_animation_position() < .14:
			fire_particles.position.x = position.x
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.14 and anim.get_current_animation_position() < .21:
			fire_particles.position.x = position.x + (last_pressed * 15)
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.21 and anim.get_current_animation_position() < .26:
			fire_particles.position.x = position.x
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.26:
			fire_particles.position.x = position.x + (last_pressed * 15)
			fire_particles.position.y = position.y + 5
	else:
		if anim.get_current_animation_position() > 0 and anim.get_current_animation_position() < .03:
			fire_particles.position.x = position.x + ((-1*last_pressed) * 15)
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.03 and anim.get_current_animation_position() < .07:
			fire_particles.position.x = position.x
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.07 and anim.get_current_animation_position() < .11:
			fire_particles.position.x = position.x + (last_pressed * 15)
			fire_particles.position.y = position.y + 5
		elif anim.get_current_animation_position() > 0.11 and anim.get_current_animation_position() < .15:
			fire_particles.position.x = position.x
			fire_particles.position.y = position.y + 5
	add_sibling(fire_particles)
	get_node("GrassTimer").start()
func _spawn_dust():
	if not get_node("DustTimer").is_stopped():
		return
	var new_dust = DustScene.instantiate()
	new_dust.position.x = position.x
	new_dust.position.y = position.y + 12
	add_sibling(new_dust)
	get_node("DustTimer").start()
func _death():
	set_physics_process(false)
	anim.play("Death")
	get_tree().call_group("worlds", "_on_player_death")
	disable_input = true
	audio_player.set_stream(death_sound)
	audio_player.play()
	velocity.y = 0
	velocity.x = 0
	await get_tree().create_timer(.5).timeout
	set_physics_process(true)
	velocity.y -= 300
	velocity.x = 0
	get_node("CollisionShape2D").set_deferred("disabled", true)
	await get_tree().create_timer(2.5).timeout
	GameState._remove_lives(1)
	get_tree().call_group("worlds", "_on_player_dead")
	get_tree().change_scene_to_file("res://main.tscn")
	
	
func _on_bounce_signal():
	bounce = true
	if jumptype == "spin" and !animplaying:
		#if GameState.big:
		
			#anim.play("BigSpin")
		#else:
			#anim.play("SmallSpin")
		_spinned()
	elif jumptype == "jump" and !animplaying:
		#if GameState.big:
			#anim.play("BigJump")
		#else:
			#anim.play("SmallJump")
		#print("wow")
		_jumped()
	#velocity.y = JUMP_VELOCITY/2
	elif !animplaying:
		_jumped()
	
func _jumped():
	#get_node("CameraTimer").start
	emit_signal("jumped")
	if velocity.x >= 225 or velocity.x <= -225:
		velocity.y = JUMP_VELOCITY - 50
	else:
		velocity.y = JUMP_VELOCITY
	#if !animplaying:
	animplaying = true
	#anim.set_speed_scale(1)
	if GameState.power == "grass":
		anim.play("GrassJump")
	elif GameState.power == "fire":
		anim.play("FireJump")
	elif GameState.power == "water":
		anim.play("WaterJump")
	elif GameState.big:
		anim.play("BigJump")
	else:
		anim.play("SmallJump")
	#print(animplaying)
	await is_on_floor()
	animplaying = false
	jumptype = "jump"
	if direction == -1:
		last_pressed = -1
	elif direction == 1: 
		last_pressed = 1
	
func _spinned():
	#get_node("CameraTimer").start
	#print("wpow")
	emit_signal("jumped")
	if (velocity.x >= 225 or velocity.x <= -225) and GameState.big:
		velocity.y = JUMP_VELOCITY -25
	elif (velocity.x < 225 or velocity.x < -225) and GameState.big:
		velocity.y = JUMP_VELOCITY + 25
	elif (velocity.x >= 225 or velocity.x <= -225) and !GameState.big:
		if bounce:
			velocity.y = JUMP_VELOCITY/2
		else: 
			velocity.y = JUMP_VELOCITY + 25
	elif (velocity.x < 225 or velocity.x < -225) and !GameState.big:
		if bounce:
			velocity.y = JUMP_VELOCITY/2
		else:
			velocity.y = JUMP_VELOCITY + 25
	#if !animplaying:
	animplaying = true
	if GameState.power == "grass":
		anim.play("GrassSpin")
	elif GameState.power == "fire":
		anim.play("FireSpin")
	elif GameState.power == "water":
			anim.play("WaterSpin")
	elif GameState.big:
		anim.play("BigSpin")
	else: 
		anim.play("SmallSpin")
	if GameState.power == "fire":
		jumptype = "spin"
		GameState.direct = 1
		var fireball1 = fireball.instantiate()
		fireball1.position.x = position.x
		fireball1.position.y = position.y
		add_sibling(fireball1)
		GameState.direct = -1
		var fireball2 = fireball.instantiate()
		fireball2.position.x = position.x
		fireball2.position.y = position.y
		add_sibling(fireball2)
	elif GameState.power == "water":
		jumptype = "spin"
		GameState.direct = 1
		var waterball1 = waterball.instantiate()
		waterball1.position.x = position.x
		waterball1.position.y = position.y
		add_sibling(waterball1)
		GameState.direct = -1
		var waterball2 = waterball.instantiate()
		waterball2.position.x = position.x
		waterball2.position.y = position.y
		add_sibling(waterball2)
	elif GameState.power == "grass":
		get_node("GrassAttack/CollisionShapeRight").disabled = false
		get_node("GrassAttack/CollisionShapeLeft").disabled = false
	await is_on_floor()
	jumptype = "spin"
	animplaying = false
	if direction == -1:
		last_pressed = -1
	elif direction == 1: 
		last_pressed = 1
	
func _gravity(delta):
	#print(bounce)
	if not is_on_floor() and (jumptype == "spin") and bounce and velocity.y <= 0:
		velocity.y += gravity * delta * 2
	elif not is_on_floor() and (jumptype == "jump") and bounce and velocity.y <= 0:
		velocity.y += gravity * delta
	elif not is_on_floor() and (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")) and !disable_input and !bounce and velocity.y < abs(JUMP_VELOCITY):
		velocity.y += gravity * delta 
		print(velocity.y < abs(JUMP_VELOCITY))
	elif not is_on_floor() and (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")) and !disable_input and bounce and velocity.y < abs(JUMP_VELOCITY):
		velocity.y += gravity * delta 
	elif not is_on_floor() and not (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")) and !disable_input and not velocity.y > abs(JUMP_VELOCITY*2):
		velocity.y += gravity * delta * 1.75
	elif disable_input:
		#print("wow")
		velocity.y += gravity * delta * 1.2
	elif is_on_floor():
		emit_signal("landed")
		if not GameState.shellkicked:
			GameState.stomp_counter = 0
		if not animplaying:
			get_tree().call_group("enemies", "_on_player_grass_attack_ended")
			get_node("GrassAttack/CollisionShapeRight").disabled = true
			get_node("GrassAttack/CollisionShapeLeft").disabled = true
		bounce = false
		jumptype = ""
		
	
func _spawn_waterballs(waterballs1, velocityx, ballposition):
	#print("ball2:   ",ballposition)
	var waterball1 = waterballs1.instantiate()
	var waterball2 = waterballs1.instantiate()
	waterball1.position = ballposition
	waterball2.position = ballposition
	waterball1.velocity.x = velocityx
	waterball2.velocity.x = velocityx
	waterball1.velocity.y = -200
	waterball2.velocity.y = -200
	waterball1.position.x += randi_range(1,20)
	waterball2.position.x += randi_range(-1,-20)
	add_child(waterball1)
	add_child(waterball2)
	
func _directionalMovement(direction):
	if direction:
		if GameState.big:
			get_node("AnimatedSprite2D").offset.y = 1
		if direction == -1 && velocity.x > 0:
			if is_on_floor():
				_spawn_dust()
			velocity.x = move_toward(velocity.x, 0, ACCELERATION*4)
		elif direction == 1 && velocity.x < 0:
			if is_on_floor():
				_spawn_dust()
			velocity.x = move_toward(velocity.x, 0, ACCELERATION*4)
		else:
			if Input.is_action_pressed("sprint"):
				velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
			else: 
				velocity.x = move_toward(velocity.x, (direction * SPEED)/3, ACCELERATION)
		if Input.is_action_pressed("down") and is_on_floor() and velocity.x and !animplaying:
			velocity.x = move_toward(velocity.x, 0, FRICTION)
			if velocity.x:
				_spawn_dust()
			get_node("AnimatedSprite2D").offset.y = 3
			if GameState.power == "grass":
				anim.play("GrassSlide")
			elif GameState.power == "fire":
				anim.play("FireSlide")
			elif GameState.power == "water":
				anim.play("WaterSlide")
			elif GameState.big:
				anim.play("BigSlide")
			else:
				anim.play("SmallSlide")
		elif velocity.y == 0 && ((velocity.x < 225 && velocity.x > 0)|| (velocity.x < 0 && velocity.x > -225)) and !animplaying:
			if GameState.power == "grass":
				anim.play("GrassWalk")
			elif GameState.power == "fire":
				anim.play("FireWalk")
			elif GameState.power == "water":
				anim.play("WaterWalk")
			elif GameState.big:
				anim.play("BigWalk")
			else:
				anim.play("SmallWalk")
		elif velocity.y == 0 && ((velocity.x >= 225 && velocity.x >= 0) || (velocity.x <= 0 && velocity.x <= -225)) and !animplaying:
			if GameState.power == "grass":
				anim.play("GrassRun")
			elif GameState.power == "fire":
				anim.play("FireRun")
			elif GameState.power == "water":
				anim.play("WaterRun")
			elif GameState.big:
				anim.play("BigRun")
			else: 
				anim.play("SmallRun")
	else:
		if velocity.y == 0 and (velocity.x > 0 or velocity.x < 0) and !animplaying:
			if GameState.power == "grass":
				anim.play("GrassWalk")
			elif GameState.power == "fire":
				anim.play("FireWalk")
			elif GameState.power == "water":
				anim.play("WaterWalk")
			elif GameState.big:
				anim.play("BigWalk")
			else:
				anim.play("SmallWalk")
		get_node("AnimatedSprite2D").offset.y = 0
		if velocity.y == 0 and not velocity.x and !animplaying:
			if GameState.power == "grass":
				anim.play("GrassIdle")
			elif GameState.power == "fire":
				anim.play("FireIdle")
			elif GameState.power == "water":
				anim.play("WaterIdle")
			elif GameState.big:
				anim.play("BigIdle")
			else:
				anim.play("SmallIdle")
		#if platVel.x != 0:
			#velocity.x = move_toward(velocity.x, 0 , ACCELERATION*20)
		#elif (get_node("AirResistanceTimer").is_stopped() or is_on_floor()):
		#print(platVel.x)
		if abs(platVel.x)> 20:
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*20)
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*2)
		elif not is_on_floor() and !plat_vel:
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*3)
			
		#elif platVel.x != 0:
			
		
		
func _on_invincible_area_body_entered(body):
	if body.name == "Player":
		#print("entered")
		GameState.invincible = true
		#get_tree().call_group("enemies", "invincible_start")
		#get_tree().call_group("shell_projectile", "invincible_start")
		#get_tree().call_group("enemy_projectiles", "invincible_start")


func _on_invincible_area_body_exited(body):
	if body.name == "Player":
		#print("exited")
		GameState.invincible = false
		#get_tree().call_group("enemies", "invincible_end")
		#get_tree().call_group("shell_projectile", "invincible_end")
		#get_tree().call_group("enemy_projectiles", "invincible_end")

