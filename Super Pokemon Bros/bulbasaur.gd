extends CharacterBody2D

@onready var audio_player = get_node("SoundEffects")
var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/kick.wav")
var SPEED = 75
var JUMP_VELOCITY = -250
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var chase = false
@onready var anim = get_node("AnimationPlayer")
#var player
var jumped_on = false
var isdead = false
signal bounce_signal
var attacked = false
var nearby
#var collided = false
#var invincible = false
signal enemy_death(body)
var animplaying = false
var start = false

func _ready(): 
	add_to_group("enemies")
	anim.play("Ground")
	#velocity.x = SPEED
	#velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	#print("invincible",invincible)
	#print("Player: ", GameState.player.position.y, "Enenmy: ", position.y/2 +90)
	#print(get_node("GroundTimer").is_stopped(), velocity.y)
	 #Add the gravity.
	#if not is_on_floor() and get_node("GroundTimer").is_stopped():
		#get_node("GroundTimer").start()
	if !isdead and start: 
		#print(GameState.player.position.y," and " ,position.y)
		if velocity.y < 0:
			anim.play("Jump")
		elif velocity.y > 0:
			anim.play("Fall")
		else:		
			anim.play("Ground")
		if not get_node("GroundTimer").is_stopped():
			velocity.x = 0
		#if is_on_floor():
			#get_node("CollisionLeft").set_deferred("disabled", false)
			#get_node("CollisionRight").set_deferred("disabled", false)
			#get_node("CollisionTop").set_deferred("disabled", false)
		if is_on_floor() and get_node("GroundTimer").is_stopped():
			velocity.y = JUMP_VELOCITY
			get_node("GroundTimer").start()
		elif not is_on_floor():
			#get_node("CollisionLeft").set_deferred("disabled", true)
			#get_node("CollisionRight").set_deferred("disabled", true)
			#get_node("CollisionTop").set_deferred("disabled", true)
			velocity.y += gravity * delta
			velocity.x = -SPEED
	else: 
		velocity.x = 0
		velocity.y = 0
	#if chase == true:
		#if !isdead:
			#get_node("AnimatedSprite2D").play("Walk")
		#player = get_node("../../Player/Player")
		#var direction = (player.position - self.position).normalized()
		#if direction.x > 0:
			#get_node("AnimatedSprite2D").flip_h = true 
		#else:
			#get_node("AnimatedSprite2D").flip_h = false
		#if !isdead:
			#velocity.x = direction.x * SPEED
	#else:
		#velocity.x = 0
	#print(invincible)
	
	move_and_slide()
	
func _on_leaf_detection_body_entered(body):
	if body.name == "Player" and !isdead:
		nearby = true

func _on_leaf_detection_body_exited(body):
	if body.name == "Player":
		nearby = false
		
func death():
	if GameState.stomp_counter == 0:
		GameState._give_score(100)
	elif GameState.stomp_counter == 1:
		GameState._give_score(200)
	elif GameState.stomp_counter == 2:
		GameState._give_score(400)
	elif GameState.stomp_counter == 3:
		GameState._give_score(500)
	elif GameState.stomp_counter == 4:
		GameState._give_score(800)
	elif GameState.stomp_counter == 5:
		GameState._give_score(1000)
	elif GameState.stomp_counter == 6:
		GameState._give_score(2000)
	elif GameState.stomp_counter == 7:
		GameState._give_score(4000)
	elif GameState.stomp_counter == 7:
		GameState._give_score(5000)
	elif GameState.stomp_counter == 8:
		GameState._give_score(8000)
	GameState.stomp_counter += 1
	#chase = false
	audio_player.set_stream(death_sound)
	if GameState.player.velocity.y > 400:
		audio_player.set_pitch_scale(1.66)
	elif GameState.player.velocity.y > 300:
		audio_player.set_pitch_scale(1.33)
	else:
		audio_player.set_pitch_scale(1)
	audio_player.play()
	get_node("PlayerHitbox/CollisionShape2D").set_deferred("disabled", true)
	get_node("CollisionShape2D").set_deferred("disabled", true)
	#get_node("CollisionTop").set_deferred("disabled", true)
	#get_node("CollisionRight").set_deferred("disabled", true)
	#get_node("CollisionLeft").set_deferred("disabled", true)
	emit_signal("enemy_death", get_path())
	anim.play("Death")
	if !attacked and jumped_on:
		emit_signal("bounce_signal")
		get_tree().call_group("player", "_spawn_kick")
	await get_tree().create_timer(0.25).timeout
	self.queue_free()
	
	#
#func invincible_start():
	#invincible = true
	#set_collision_mask_value(1, false)
	#
#func invincible_end():
	#invincible = false
	#set_collision_mask_value(1, true)

func _on_player_grass_attack():
	attacked = true
	jumped_on = false
	if nearby:
		isdead = true
		death()

func _on_player_grass_attack_ended():
	attacked = false

func is_above():
	return GameState.player.position.y < position.y +90 and GameState.player.velocity.y > 0


func _on_player_hitbox_body_entered(body):
	if body.name == "Player" and not isdead and !GameState.invincible and is_above():
		jumped_on = true
		death()
		isdead=true
	elif body.is_in_group("projectiles") and not isdead:
		jumped_on = false
		if body.is_in_group("shell_projectile"):
			GameState.shellkicked = true
			get_tree().call_group("shell_projectile", "_start_timer")
		death()
		isdead=true
	elif body.name == "Player" and !isdead and !GameState.invincible:
		if GameState.big and GameState.power == "":
			GameState.big = false
		elif GameState.big and GameState.power != "":
			GameState.big = true
			GameState.power = ""
		else:
			#get_node("AnimatedSprite2D").queue_free()
			get_tree().call_group("player", "_death")



func _on_player_detection_body_entered(body):
	if body.name == "Player":
		start = true
		

