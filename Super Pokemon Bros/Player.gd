extends CharacterBody2D

const SPEED = 275.0
const JUMP_VELOCITY = -400.0
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
var attack = ""
var scaleup = false
var scaledown = false
signal grass_attack
signal grass_attack_ended
var target_left_margin = 0.0
var target_right_margin = 0.0
signal jumped
signal landed
var min = 0
func _ready():
	get_node("GrassAttack/CollisionShapeRight").disabled = true
	get_node("GrassAttack/CollisionShapeLeft").disabled = true
	
func emit_signal_while_playing(direction):
	while anim.is_playing():
		get_tree().call_group("enemies", "_on_player_grass_attack")
		get_tree().call_group("question_block", "_grass_attack")
		#emit_signal("grass_attack")
		#if velocity.x - 50 == min and animplaying and attack == "grass" and not velocity.x == 0:
			#velocity.x = move_toward(velocity.x, velocity.x - 50, 50)
		#elif velocity.x +50 == min and animplaying and attack == "grass" and not velocity.x == 0:
			#velocity.x = move_toward(velocity.x, velocity.x + 50, 50)
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
	print(animplaying)
	var direction = Input.get_axis("ui_left", "ui_right")
	#if Input.is_action_just_pressed("attack"):
		#emit_signal("grass_attack")
		#attack = "grass"
		#animplaying = true
		#anim.play("GrassAttack")		
		#await anim.animation_finished
		#animplaying = false
		#emit_signal("grass_attack")
	if Input.is_action_just_pressed("attack") and !animplaying:	
			if last_pressed == -1:
				get_node("GrassAttack/CollisionShapeLeft").disabled = false
			elif last_pressed == 1:
				get_node("GrassAttack/CollisionShapeRight").disabled = false
			attack = "grass"
			animplaying = true
			anim.play("GrassAttack")
			if velocity.x > 0:
				min = velocity.x-50
			else:
				min = velocity.x+50
			emit_signal_while_playing(direction)
	get_node("Camera2D").position.x = get_node("AnimatedSprite2D").position.x
	get_node("Camera2D").position.y = 0
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 1.2
	else:
		emit_signal("landed")
	#if not is_on_floor() and velocity.y > 0:
		#get_node("CollisionShape2D").disabled = false
		#get_node("Area2D/CollisionShape2D").disabled = false
	#elif not is_on_floor() and velocity.y <= 0:
		#get_node("CollisionShape2D").disabled = true
		#get_node("Area2D/CollisionShape2D").disabled = true
	# Handle jump
	#if get_node("DustTimer").is_stopped():
		#get_node("Dust").visible = false
	#else:
		#var new_dust = DustScene.instantiate()
		#new_dust.visible = true
		#new_dust.position.x = position.x + 8
		#new_dust.position.y = position.y + 32
		#add_sibling(new_dust)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		emit_signal("jumped")
		if velocity.x >= 275 or velocity.x <= -275:
			velocity.y = JUMP_VELOCITY - 50
		else:
			velocity.y = JUMP_VELOCITY
		if !animplaying:
			animplaying = true
			anim.play("JumpBig")
			animplaying = false
			jumptype = "jump"
		if direction == -1:
			last_pressed = -1
		elif direction == 1: 
			last_pressed = 1
	if Input.is_action_just_pressed("spinjump") and is_on_floor():
		emit_signal("jumped")
		if velocity.x >= 275 or velocity.x <= -275:
			velocity.y = JUMP_VELOCITY 
		else:
			velocity.y = JUMP_VELOCITY + 50
		if !animplaying:
			animplaying = true
			anim.play("SpinBig")
			jumptype = "spin"
			await not is_on_floor()
			animplaying = false
		if direction == -1:
			last_pressed = -1
		elif direction == 1: 
			last_pressed = 1
	if (!Input.is_action_pressed("spinjump") and !Input.is_action_pressed("ui_accept")) and velocity.y < 0:
		velocity.y += gravity*delta
	if !Input.is_action_pressed("down") and is_on_floor():
			get_node("AnimatedSprite2D").offset.y = 0
	if Input.is_action_just_pressed("down") and velocity.x:
			get_node("AnimatedSprite2D").offset.y = 3
	if last_pressed == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif last_pressed == 1:
		get_node("AnimatedSprite2D").flip_h = false

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
		anim.play("FallBig")
	get_node("Camera2D").drag_left_margin = lerp(get_node("Camera2D").drag_left_margin, target_left_margin, MARGIN_CHANGE_SPEED * delta)
	get_node("Camera2D").drag_right_margin = lerp(get_node("Camera2D").drag_right_margin, target_right_margin, MARGIN_CHANGE_SPEED * delta)
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
		anim.play("Spin")
	elif jumptype == "jump" and !animplaying:
		anim.play("JumpBig")
	velocity.y = JUMP_VELOCITY/3
	
func _directionalMovement(direction):
	if direction:
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
			anim.play("SlideBig")
		elif velocity.y == 0 && ((velocity.x < 275 && velocity.x > 0)|| (velocity.x < 0 && velocity.x > -275)) and !animplaying:
			anim.play("WalkBig")
		elif velocity.y == 0 && ((velocity.x >= 275 && velocity.x >= 0) || (velocity.x <= 0 && velocity.x <= -275)) and !animplaying:
			anim.play("GrassRun")
	else:
		if velocity.y == 0 and (velocity.x > 0 or velocity.x < 0) and !animplaying:
			anim.play("WalkBig")
		get_node("AnimatedSprite2D").offset.y = 0
		if velocity.y == 0 and not velocity.x and !animplaying:
			anim.play("IdleBig")
		velocity.x = move_toward(velocity.x, 0 , ACCELERATION*2)
		
	
