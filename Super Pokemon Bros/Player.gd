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
var drum_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/countdown.wav")
var game_over_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/smw_game_over.wav")
var fireball = preload("res://fireball.tscn")
var waterball = preload("res://waterball.tscn")
const SPEED = 225.00
const JUMP_VELOCITY = -250.0
const FRICTION = 35
const ACCELERATION = 5.0
var MARGIN_CHANGE_SPEED = 10.0
var on_pipe = false
var platVel = Vector2(0,0)
var subtract = false
var subtract_timer_started = false
var disable_input = false
var display_point_screen = false
var last_platform_y = 0.0
var audio_played = false
var cutscene_played = false
var final_cutscene = false
var plat_vel = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
var DustScene = preload("res://dust.tscn")
var BubbleScene = preload("res://bubble.tscn")
var KickScene = preload("res://kick.tscn")
var animplaying = false
var jumptype = ""
var last_pressed = 0
var bounce = false
var last_pos = 0.0
signal grass_attack
signal grass_attack_ended
signal invincibility
var target_left_margin = 0.0
var target_right_margin = 0.0
var target_top_margin = 0.0
var target_bottom_margin = 0.0
signal jumped
signal landed
var follow_player = false
var min_vel = 0
var scaled = false
var scaling = false
var direction
var played = false 
var collected = "small"
func _ready():
	add_to_group("player")
	GameState.player = self
	GameState.display_power()
	get_node("Camera2D/GameTransition/ColorRect").set_visible(false)
	get_node("Camera2D/GameTransition/ColorRect2").set_visible(false)
	get_node("Camera2D/GameTransition/ColorRect3").set_visible(false)
	get_node("Camera2D/GameEndFade/ColorRect").set_visible(false)
	get_node("GrassAttack/CollisionShapeRight").disabled = true
	get_node("GrassAttack/CollisionShapeLeft").disabled = true
	scale = Vector2(.90,.90) 
func _start_pipe_helper():
	collected = GameState.power
	if GameState.big:
		scaled = true
		scale = Vector2(1.1,1.1)
	else:
		scale = Vector2(.9,.9)
	set_z_index(-1)
	set_physics_process(false)
	disable_input = true
	if GameState.power == "fire":
		anim.play("FirePipe")
	elif GameState.power == "water":
		anim.play("WaterPipe")
	elif GameState.power == "grass":
		anim.play("GrassPipe")
	elif GameState.big:
		anim.play("BigPipe")
	else:
		anim.play("SmallPipe")
	audio_player.set_stream(powerdown_sound)
	audio_player.play()
func end_pipe_helper(anim_name):
	if anim_name == "pipe_load" or anim_name == "pipe_exit":
		set_z_index(2)
		set_physics_process(true)
		disable_input = false
		get_tree().call_group("status_bar", "_timer_loop")
func emit_signal_while_playing():
	while anim.is_playing():
		if get_node("GrassTimer").is_stopped():
			_spawn_particles()
		anim.set_speed_scale(1)
		get_tree().call_group("enemies", "_on_player_grass_attack")
		get_tree().call_group("enemy_projectiles", "_on_player_grass_attack")
		get_tree().call_group("question_block", "_grass_attack")
		if velocity.x - 50 == min_vel and animplaying and GameState.power == "grass" and abs(velocity.x) > 50:
			velocity.x = move_toward(velocity.x, velocity.x - 50, 50)
		elif velocity.x +50 == min_vel and animplaying and GameState.power == "grass" and abs(velocity.x) > 50:
			velocity.x = move_toward(velocity.x, velocity.x + 50, 50)
		await get_tree().create_timer(0.0).timeout
	animplaying = false
	get_tree().call_group("enemies", "_on_player_grass_attack_ended")
	if last_pressed == -1:
		get_node("GrassAttack/CollisionShapeLeft").disabled = true
	elif last_pressed == 1:
		get_node("GrassAttack/CollisionShapeRight").disabled = true

func _physics_process(delta):
	if not is_on_floor() and get_node("RayCast2D").is_colliding() and !GameState.water_gravity and velocity.y > 0 and !disable_input:
		get_node("JustLanded").start()
		follow_player = true
	elif is_on_floor() and follow_player == true and !GameState.water_gravity and !disable_input:
		get_node("JumpDelay").start()
		get_node("CameraDelayTimer").start()
		get_node("Camera2D").drag_bottom_margin = 1.00
		follow_player = false

		if direction == -1:
			last_pressed = -1
		elif direction == 1: 
			last_pressed = 1
		
	if GameState.water_gravity and get_node("BubbleTimer").is_stopped() and !disable_input:
		_spawn_bubble()
		get_node("BubbleTimer").set_wait_time(randf_range(.5,1))

	if GameState.cutscene and !cutscene_played:
		GameState.invincible = true
		disable_input = true
		if not display_point_screen:
			get_node("Camera2D/PointScreen/PointNotifier").play("visibility")
		get_node("Camera2D").drag_right_margin = lerp(get_node("Camera2D").drag_right_margin, 0.0, MARGIN_CHANGE_SPEED *delta)
		get_node("Camera2D").drag_left_margin = lerp(get_node("Camera2D").drag_left_margin, 0.0, MARGIN_CHANGE_SPEED *delta)
		if last_pressed == -1:
			GameState.direct = 1
			get_node("AnimatedSprite2D").flip_h = false
		elif last_pressed == 1:
			GameState.direct = 1
			get_node("AnimatedSprite2D").flip_h = false
		anim.set_speed_scale(abs(velocity.x)/100)
		velocity.x = move_toward(velocity.x, 75, ACCELERATION)
		if GameState.power == "grass":
			anim.play("GrassWalk")
		elif GameState.power == "water":
			anim.play("WaterWalk")
		elif GameState.power == "fire":
			anim.play("FireWalk")
		elif GameState.big:
			anim.play("BigWalk")
		elif not GameState.big:
			anim.play("SmallWalk")
		if display_point_screen and not subtract_timer_started:
			subtract_timer_started = true
			get_node("SubtractTimer").start()
		if get_node("SubtractTimer").is_stopped() and subtract_timer_started == true:
			if not audio_played:
				audio_played = true
				get_node("SoundEffects").set_volume_db(-10)
				get_node("SoundEffects").set_stream(drum_sound)
				get_node("SoundEffects").play()
			if GameState.total_points != 0:
				if GameState.total_points >= 100:
					GameState._give_score(100)
				elif GameState.total_points >= 50:
					GameState._give_score(50)
				elif GameState.total_points >= 10:
					GameState._give_score(10)
				
			get_tree().call_group("point_screen", "_subtract")
		if final_cutscene and !cutscene_played:
			get_node("Camera2D/GameTransition").set_visible(true)
			cutscene_played = true
			velocity.x = 0
			if GameState.power == "grass":
				anim.play("CelebrationGrass")
			elif GameState.power == "water":
				anim.play("CelebrationWater")
			elif GameState.power == "fire":
				anim.play("CelebrationFire")
			elif GameState.big:
				anim.play("CelebrationBig")
			elif not GameState.big:
				anim.play("CelebrationSmall")
			await anim.animation_finished
			get_node("Camera2D").drag_right_margin = 1
			velocity.x = move_toward(velocity.x, 75, 50)
			if GameState.power == "grass":
				anim.play("GrassWalk")
			elif GameState.power == "water":
				anim.play("WaterWalk")
			elif GameState.power == "fire":
				anim.play("FireWalk")
			elif GameState.big:
				anim.play("BigWalk")
			elif not GameState.big:
				anim.play("SmallWalk")
			await get_tree().create_timer(.35).timeout
			get_node("Camera2D/GameTransition/FadePlayer").play("fade")
			if get_tree().current_scene.name == "World1":
				GameState.checkpoint_level_1 = false
			elif get_tree().current_scene.name == "World2":
				GameState.checkpoint_level_2 = false
			await get_node("Camera2D/GameTransition/FadePlayer").animation_finished
			GameState.cutscene = false
			GameState.invincible = false
			GameState.big_num_coins = 0
			GameState.num_coins = 0
			get_tree().call_group("worlds", "_on_player_dead")
			GameState.next_scene = "res://world_select.tscn"
			get_tree().change_scene_to_packed(GameState.loading_screen)
			queue_free()
	if !GameState.water_gravity:
		if (is_on_floor() and (position.y != last_pos)):
			get_node("Camera2D").drag_top_margin = 0.00
			last_pos = position.y
			if last_pos > last_platform_y:
				last_platform_y = last_pos
			if !get_node("JustLanded").is_stopped():
				get_node("Camera2D").drag_bottom_margin = 1.00
			else:
				get_node("Camera2D").drag_bottom_margin = 0.00
		elif not is_on_floor() and last_pos > position.y:
			get_node("Camera2D").drag_bottom_margin = 1.00
		elif not is_on_floor() and get_node("JumpDelay").is_stopped():
			if last_pos < position.y:
				get_node("Camera2D").drag_bottom_margin = 0.00
			get_node("Camera2D").global_position.y = move_toward(get_node("Camera2D").global_position.y, position.y, MARGIN_CHANGE_SPEED*60 * delta)
		get_node("Camera2D").global_position.y = move_toward(get_node("Camera2D").global_position.y, last_pos, MARGIN_CHANGE_SPEED*20 * delta)

	if not scaling:
		_gravity(delta)
	if !disable_input:

		if not get_node("Invincibility").is_stopped() and played:
			get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, randi_range(.8,1)))
		elif get_node("Invincibility").is_stopped() and played:
			GameState.invincible = false
			get_node("AnimatedSprite2D").set_self_modulate(Color(1, 1, 1, 1))
			played = false
		if scaling:
			GameState.invincible = true
			scaling = false
			anim.stop(false)
			set_physics_process(false)
			if not scaled:
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
			anim.play()
			set_physics_process(true)
			if scaled:
				position.y -= 2
			if get_node("Invincibility").is_stopped():
				GameState.invincible = false
		else:
			get_node("AnimatedSprite2D").set_visible(1)
		if GameState.power == "grass" and collected != "grass":
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scaled = false
			scale = Vector2(1.1,1.1)
			collected = "grass"
			scaling = true
			await get_tree().create_timer(.40).timeout
			scaled = true
		elif GameState.power == "water" and collected != "water":
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scaled = false
			scale = Vector2(1.1,1.1)
			collected = "water"
			scaling = true
			await get_tree().create_timer(.40).timeout
			scaled = true
		elif GameState.power == "fire" and collected != "fire":
			GameState.display_power()
			audio_player.set_stream(powerup_sound)
			audio_player.play()
			scaled = false
			scale = Vector2(1.1,1.1)
			collected = "fire"
			scaling = true
			await get_tree().create_timer(.40).timeout
			scaled = true
		elif GameState.power == "" and GameState.big and (collected == "fire" or collected == "water" or collected == "grass"):
			GameState.display_power()
			powerup_player.set_stream(powerdown_sound)
			powerup_player.play()
			scaled = false
			collected = "big"
			scaling = true
			get_node("Invincibility").start()
			await get_tree().create_timer(.40).timeout
			scaled = true
		elif GameState.big and not scaled:
			GameState.display_power()
			powerup_player.set_stream(powerup_sound)
			powerup_player.play()
			scale = Vector2(1.1,1.1)
			collected = "big"
			scaling = true
			
			await get_tree().create_timer(.40).timeout
			scaled = true
		elif !GameState.big and scaled:
			GameState.display_power()
			powerup_player.set_stream(powerdown_sound)
			powerup_player.play()
			scale = Vector2(.90,.90)
			collected = "small"
			scaling = true
			get_node("Invincibility").start()
			await get_tree().create_timer(.40).timeout
			scaled = false
		if not is_on_floor() and jumptype == "spin" and GameState.power == "grass":
			get_tree().call_group("enemies", "_on_player_grass_attack")
			get_tree().call_group("enemy_projectiles", "_on_player_grass_attack")
			get_tree().call_group("question_block", "_grass_attack")
			if get_node("GrassTimer").is_stopped():
				_spawn_particles()
		direction = Input.get_axis("ui_left", "ui_right")
		if Input.is_action_just_pressed("attack") and !animplaying and GameState.power != "":	
				if GameState.power == "grass":
					if last_pressed == -1:
						get_node("GrassAttack/CollisionShapeLeft").disabled = false
					elif last_pressed == 1:
						get_node("GrassAttack/CollisionShapeRight").disabled = false
					animplaying = true
					powerup_player.set_stream(spin_sound)
					powerup_player.play()
					anim.play("GrassAttack")
					if velocity.x > 0:
						min_vel = velocity.x-50
					else:
						min_vel = velocity.x+50
					emit_signal_while_playing()
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
					var waterball1 = waterball.instantiate()
					waterball1.position.x = position.x
					waterball1.position.y = position.y
					add_sibling(waterball1)
					await anim.animation_finished
					animplaying = false
		if !GameState.water_gravity:
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				audio_player.set_stream(jump_sound)
				audio_player.play()
				if abs(platVel.x) > 20:
					plat_vel = true
				else:
					plat_vel = false
				_jumped()
					
			if Input.is_action_just_pressed("spinjump") and is_on_floor():
				audio_player.set_stream(spin_sound)
				audio_player.play()
				if abs(platVel.x) > 20:
					plat_vel = true
				else:
					plat_vel = false
				_spinned()
		else:
			if Input.is_action_just_pressed("ui_accept"):
				audio_player.set_stream(jump_sound)
				audio_player.play()
				_water_jumped()
			
		if !Input.is_action_pressed("down") and is_on_floor() and !GameState.big:
			get_node("AnimatedSprite2D").offset.y = 0
		if Input.is_action_just_pressed("down") and velocity.x:
			get_node("AnimatedSprite2D").offset.y = 3
		if ((Input.is_action_pressed("down") and on_pipe)) or ((Input.is_action_pressed("up") and on_pipe and GameState.water_gravity)):
			if !GameState.water_gravity:
				get_node("Camera2D").drag_top_margin = 0.00
				get_node("Camera2D").drag_bottom_margin = 1.00
				get_tree().call_group("worlds", "surface_pipe_entered")
			else:
				get_node("Camera2D").drag_top_margin = 1.00
				get_node("Camera2D").drag_bottom_margin = 0.00
				get_tree().call_group("worlds", "underwater_pipe_entered")
		if last_pressed == -1:
			GameState.direct = -1
			get_node("AnimatedSprite2D").flip_h = true
		elif last_pressed == 1:
			GameState.direct = 1
			get_node("AnimatedSprite2D").flip_h = false
		if abs(velocity.x) >= 30 and velocity.x:
			if is_on_floor():
				anim.set_speed_scale(abs(velocity.x)/100)
			else:
				anim.set_speed_scale(1)
		else:
			anim.set_speed_scale(1)
		if direction:
			if !GameState.water_gravity:
				if get_node("AnimatedSprite2D").global_position[0] > 30 + get_node("Camera2D").get_screen_center_position()[0]:

					target_right_margin = 0.0
				elif get_node("AnimatedSprite2D").global_position[0] < get_node("Camera2D").get_screen_center_position()[0] - 30:
					target_left_margin = 0.0
			if !GameState.water_gravity:
				_directionalMovement()
			else:
				_waterDirectionalMovement()
			if direction < 0:
				last_pressed = -1
			else: 
				last_pressed = 1
		else:
			if !GameState.water_gravity:
				_directionalMovement()
				if last_pressed == 1:
					target_left_margin = 0.3
				elif last_pressed == -1:
					target_right_margin = 0.3
			else:
				_waterDirectionalMovement()
			
		if velocity.y > 0 and !animplaying and jumptype=="jump" and !GameState.water_gravity:
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
func _spawn_bubble():
	if not get_node("BubbleTimer").is_stopped():
		return
	var BubbleScene1 = BubbleScene.instantiate()
	BubbleScene1.position.x = position.x
	BubbleScene1.position.y = position.y - 5
	add_sibling(BubbleScene1)
	get_node("BubbleTimer").start()
func _death():
	get_node("Camera2D").set_limit(3, (get_node("Camera2D").get_screen_center_position().y + (get_viewport().size.y/9)))
	get_node("Camera2D").drag_top_margin = 1.00
	get_node("Camera2D").drag_bottom_margin = 0.00
	get_node("Camera2D").set_process_mode(3)
	velocity.y = 0
	velocity.x = 0
	get_node("Camera2D").set_process_mode(3)
	set_physics_process(false)
	anim.play("Death")
	get_tree().call_group("status_bar", "stop_time")
	get_tree().call_group("worlds", "_on_player_death")
	disable_input = true
	audio_player.set_stream(death_sound)
	audio_player.play()
	await get_tree().create_timer(.5).timeout
	set_physics_process(true)
	if GameState.water_gravity:
		velocity.y -= 200
	else:
		velocity.y -= 300
	velocity.x = 0
	get_node("CollisionShape2D").set_deferred("disabled", true)
	if GameState.num_lives == 1:
		await get_tree().create_timer(2.2).timeout
		get_node("Camera2D/GameOverScreen").set_visible(true)
		get_node("Camera2D/GameOverScreen/ColorRect").set_visible(true)
		get_node("Camera2D/GameOverScreen/GameOver").play("game_over")
		get_node("GameOver").play()
		GameState.curr_world = 0
		GameState.checkpoint_level_1 = false
		GameState.checkpoint_level_2 = false
		GameState.checkpoint_level_3 = false
		GameState.world_unlock = 1
		GameState.num_lives = 5
		GameState.num_coins = 0
		GameState.score = 0
		await get_node("Camera2D/GameOverScreen/GameOver").animation_finished
		GameState.next_scene = "res://starting_scene.tscn"
		get_tree().call_group("worlds", "_on_player_dead")
		get_tree().change_scene_to_packed(GameState.loading_screen)
		queue_free()
	else:
		await get_tree().create_timer(2.4).timeout
		GameState._remove_lives(1)
		GameState.big_num_coins = 0
		GameState.next_scene = "res://world_select.tscn"
		get_node("Camera2D/CanvasLayer/LoadingScreenTransition").set_visible(true)
		get_node("Camera2D/CanvasLayer/LoadingScreenTransition/FadePlayer1").play("fade_out")

func _on_bounce_signal():
	bounce = true
	if jumptype == "spin" and !animplaying:
		_spinned()
	elif jumptype == "jump" and !animplaying:
		_jumped()
	elif !animplaying:
		_jumped()
func _water_jumped():
	velocity.y = JUMP_VELOCITY/3
	if !animplaying:
		if GameState.power == "grass":
			anim.play("GrassSwim")
		elif GameState.power == "fire":
			anim.play("FireSwim")
		elif GameState.power == "water":
			anim.play("WaterSwim")
		elif GameState.big:
			anim.play("BigSwim")
		else:
			anim.play("SmallSwim")

func _jumped():
	if abs(position.y - last_platform_y) <= 10 or get_node("CameraDelayTimer").is_stopped():
		get_node("Camera2D").drag_top_margin = 1.00
	last_platform_y = position.y
	emit_signal("jumped")
	jumptype = "jump"
	if velocity.x >= 225 or velocity.x <= -225:
		velocity.y = JUMP_VELOCITY - 50
	else:
		velocity.y = JUMP_VELOCITY
	animplaying = false
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
	
func _spinned():
	if abs(position.y - last_platform_y) <= 10 or get_node("CameraDelayTimer").is_stopped():
		get_node("Camera2D").drag_top_margin = 1.00
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
	animplaying = false
	jumptype = "spin"
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
	
func _gravity(delta):
	if disable_input and get_node("AnimationPlayer").get_assigned_animation() == "Death" and not GameState.water_gravity:
		velocity.y += gravity * delta * 1.5
	elif GameState.water_gravity and not is_on_floor() and disable_input and get_node("AnimationPlayer").get_assigned_animation() == "Death":
		velocity.y += gravity * delta * 2.5
	elif not is_on_floor() and (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")) and !disable_input and bounce and velocity.y < abs(JUMP_VELOCITY):
		velocity.y += gravity * delta 
	elif not is_on_floor() and not (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")) and !disable_input and not velocity.y > abs(JUMP_VELOCITY*2):
		velocity.y += gravity * delta * 1.75
	elif not is_on_floor() and (jumptype == "spin") and bounce and velocity.y <= 0:
		velocity.y += gravity * delta * 3
	elif not is_on_floor() and (jumptype == "jump") and bounce and velocity.y <= 0:
		velocity.y += gravity * delta
	elif not is_on_floor() and (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")) and !disable_input and !bounce and velocity.y < abs(JUMP_VELOCITY):
		velocity.y += gravity * delta 
	elif is_on_floor() and !disable_input:
		emit_signal("landed")
		if not GameState.shellkicked:
			GameState.stomp_counter = 0
		if not animplaying:
			get_tree().call_group("enemies", "_on_player_grass_attack_ended")
			get_node("GrassAttack/CollisionShapeRight").disabled = true
			get_node("GrassAttack/CollisionShapeLeft").disabled = true
		bounce = false
		jumptype = ""
	else:
		velocity.y += gravity * delta
		
func _waterDirectionalMovement():
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
			velocity.x = move_toward(velocity.x, (direction * SPEED)/3, ACCELERATION)
			if !animplaying and is_on_floor() and get_floor_angle() == 0:
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
			else:
				if !animplaying:
					if GameState.power == "grass":
						anim.play("GrassSwim")
					elif GameState.power == "fire":
						anim.play("FireSwim")
					elif GameState.power == "water":
						anim.play("WaterSwim")
					elif GameState.big:
						anim.play("BigSwim")
					else:
						anim.play("SmallSwim")
	else:
		get_node("AnimatedSprite2D").offset.y = 0
		if is_on_floor() and get_floor_angle() == 0 and not velocity.x and !animplaying and velocity.y == 0:
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
		elif not velocity.y and not is_on_floor():
			if GameState.power == "grass":
				anim.play("GrassSwimIdle")
			elif GameState.power == "fire":
				anim.play("FireSwimIdle")
			elif GameState.power == "water":
				anim.play("WaterSwimIdle")
			elif GameState.big:
				anim.play("BigSwimIdle")
			else:
				anim.play("SmallSwimIdle")
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*2)
		
func _directionalMovement():
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

		if abs(platVel.x)> 20:
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*20)
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*2)
		elif not is_on_floor() and !plat_vel:
			velocity.x = move_toward(velocity.x, 0 , ACCELERATION*3)

func _on_invincible_area_body_entered(body):
	if body.name == "Player":
		GameState.invincible = true

func _on_invincible_area_body_exited(body):
	if body.name == "Player":
		GameState.invincible = false

func _on_fade_player_animation_finished(anim_name):
	if anim_name == "fade":
		final_cutscene = true

func _on_point_notifier_animation_finished(anim_name):
	if anim_name == "visibility":
		display_point_screen = true
	if anim_name == "subtract":
		subtract = true

func _set_camera_limits():
	get_node("Camera2D").set_limit(3, (get_node("Camera2D").get_screen_center_position().y + (get_viewport().size.y/9)))

func _on_finish_area_2d_body_entered(body):
	if body.name == "Player":
		get_node("Camera2D/GameEndFade/FadePlayer1").play("fade")
		set_z_index(7)
		GameState.cutscene = true

func _on_pipe_area_body_entered(body):
	if body.name == "Player":
		on_pipe = true

func _on_pipe_area_body_exited(body):
	if body.name == "Player":
		on_pipe = false

func _on_loading_screen_animation_finished(anim_name):
	if anim_name == "fade_out" || anim_name == "fade_out_death":
		get_tree().call_group("worlds", "_on_player_dead")
		get_tree().change_scene_to_packed(GameState.loading_screen)
		queue_free()
