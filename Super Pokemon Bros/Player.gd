class_name Player
extends CharacterBody2D
var fireball = preload("res://fireball.tscn")
var waterball = preload("res://waterball.tscn")
const SPEED = 250.0
const JUMP_VELOCITY = -300.0
const FRICTION = 35
const ACCELERATION = 5.0
const MARGIN_CHANGE_SPEED = 10.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
var DustScene = preload("res://dust.tscn")
var animplaying = false
var jumptype = ""
var last_pressed = 0
var changeddirection = false
var skid = false
var curr_pos = 0
#var attack = ""
var scaleup = false
var scaledown = false
var move = true
signal grass_attack
signal grass_attack_ended
signal invincibility
var target_left_margin = 0.0
var target_right_margin = 0.0
signal jumped
signal landed
var min = 0
var scaled = false
var scaling = false
var direction
var played = false 
var collected = "small"
func _ready():
	GameState.player = self
	get_node("GrassAttack/CollisionShapeRight").disabled = true
	get_node("GrassAttack/CollisionShapeLeft").disabled = true
	scale = Vector2(.90,.90)
	
func emit_signal_while_playing(direction):
	while anim.is_playing():
		anim.set_speed_scale(1)
		get_tree().call_group("enemies", "_on_player_grass_attack")
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
	if last_pressed == -1:
				get_node("GrassAttack/CollisionShapeLeft").disabled = true
	elif last_pressed == 1:
		get_node("GrassAttack/CollisionShapeRight").disabled = true
	get_tree().call_group("enemies", "_on_player_grass_attack_ended")
	#get_tree().call_group("question_block", "_grass_attack")
	#emit_signal("grass_attack_ended")
func _physics_process(delta):
	#print("PlayerPos: ", position.y)
	#print(GameState.game_ended)
	#print(collected, GameState.big, scaled)
	#print(anim.get_speed_scale())
	if not get_node("Invincibility").is_stopped() and played:
		#emit_signal("invincibility")
		#add_to_group("invincibility")
		get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, randi_range(.95,1)))
	else:
		get_tree().call_group("enemies", "invincible_end")
		get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
	#if GameState.big:
		#scale = Vector2(1.1,1.1)
	#else:
		#scale = Vector2(.9,.9)
	#print("power:",GameState.power,"collect:" ,collected, "big:", GameState.big)
	if scaling:
		get_tree().call_group("enemies", "invincible_start")
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
			#anim.play("Celebration")
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.2))
			scale = Vector2(1.0,1.0)
			await get_tree().create_timer(.05).timeout
			GameState.big = false
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
			scale = Vector2(.90,.90)
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.2))
			scale = Vector2(1.0,1.0)
			await get_tree().create_timer(.05).timeout
			GameState.big = false
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
			scale = Vector2(.90,.90)
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.2))
			scale = Vector2(1.00,1.00)
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
			scale = Vector2(1.10,1.10)
			await get_tree().create_timer(.05).timeout
			GameState.big = false
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.2))
			scale = Vector2(1.00,1.00)
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
			scale = Vector2(1.10,1.10)
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 0.2))
			scale = Vector2(1.0,1.0)
			await get_tree().create_timer(.05).timeout
			GameState.big = true
			#get_node("AnimatedSprite2D").set_modulate(Color(1, 1, 1, 1))
			scale = Vector2(1.1,1.1)
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
		scaled = false
		print("wow")
		#GameState.power == "big
		collected = "big"
		scaling = true
		await get_tree().create_timer(.40).timeout
		scaled = true
	elif GameState.big and not scaled:
		scale = Vector2(1.1,1.1)
		collected = "big"
		scaling = true
		
		await get_tree().create_timer(.40).timeout
		scaled = true
	#elif GameState.big and GameState.power != "":
	elif !GameState.big and scaled:
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
				anim.play("GrassAttack")
				if velocity.x > 0:
					min = velocity.x-50
				else:
					min = velocity.x+50
				emit_signal_while_playing(direction)
			elif GameState.power == "fire":
				animplaying = true
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
	if not scaling:
		_gravity(delta)
	#print(GameState.split)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_jumped()
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
		_spinned()
		#if velocity.x >= 250 or velocity.x <= -250:
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
			
	if (!Input.is_action_pressed("spinjump") and !Input.is_action_pressed("ui_accept")) and velocity.y < 0:
		velocity.y += gravity*delta
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
		if get_node("AnimatedSprite2D").global_position[0] > 35 + get_node("Camera2D").get_screen_center_position()[0]:
			target_right_margin = 0.0
		elif get_node("AnimatedSprite2D").global_position[0] < get_node("Camera2D").get_screen_center_position()[0] - 35:
			target_left_margin = 0.0
		_directionalMovement(direction)
		if direction < 0:
			last_pressed = -1
		else: 
			last_pressed = 1
	else:
		_directionalMovement(direction)
		if last_pressed == 1:
			target_left_margin = 0.2
		elif last_pressed == -1:
			target_right_margin = 0.2
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
	if move:
		move_and_slide()
	
func _spawn_dust():
	if not get_node("DustTimer").is_stopped():
		return
	var new_dust = DustScene.instantiate()
	new_dust.position.x = position.x
	new_dust.position.y = position.y + 14
	add_sibling(new_dust)
	get_node("DustTimer").start()
	
func _on_charmander_bounce_signal():
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
	
func _jumped():
	emit_signal("jumped")
	if velocity.x >= 250 or velocity.x <= -250:
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
	emit_signal("jumped")
	if velocity.x >= 250 or velocity.x <= -250:
		velocity.y = JUMP_VELOCITY -25
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
	jumptype = "spin"
	await is_on_floor()
	animplaying = false
	if direction == -1:
		last_pressed = -1
	elif direction == 1: 
		last_pressed = 1
	
func _gravity(delta):
	if not is_on_floor() and (Input.is_action_pressed("spinjump") or Input.is_action_pressed("ui_accept")):
		velocity.y += gravity * delta
	elif not is_on_floor():

		velocity.y += gravity * delta * 2
	else:
		emit_signal("landed")
		jumptype = ""
		
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
		velocity.x = move_toward(velocity.x, 0 , ACCELERATION*2)
		
	
