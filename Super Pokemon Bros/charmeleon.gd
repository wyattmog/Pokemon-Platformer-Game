extends CharacterBody2D


var SPEED = 75
var JUMP_VELOCITY = -300
@onready var audio_player = get_node("SoundEffects")
var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/kick.wav")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var chase = false
var fireball = preload("res://enemy_fireball.tscn")
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
var in_range = false
func _ready(): 
	add_to_group("enemies")
	anim.play("Idle")
	#velocity.x = SPEED
	#velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	#print(get_node("GroundTimer").is_stopped(), velocity.y)
	 #Add the gravity.
	#if not is_on_floor() and get_node("GroundTimer").is_stopped():
		#get_node("GroundTimer").start()
	if !isdead and start:
		var direction = (GameState.player.position - self.position)
		#print(GameState.player.position.x," and ", self.position.x)
		if direction.x > 0:
			get_node("AnimatedSprite2D").flip_h = true 
			#GameState.projectile_adjustment = -60
			
			#position.y -= 1
			#velocity.x = -SPEED*2
		else:
			#GameState.projectile_adjustment = 0
			#position.y -= 1
			get_node("AnimatedSprite2D").flip_h = false
		#print(GameState.player.position.y," and " ,position.y)
		if velocity.y < 0 and !animplaying:
			anim.play("Jump")
		elif velocity.y > 0 and !animplaying:
			anim.play("Fall")
		elif velocity.y == 0 and !animplaying:		
			anim.play("Idle")
		if is_on_floor() and get_node("GroundTimer").is_stopped() and in_range:
			velocity.y = JUMP_VELOCITY
			get_node("GroundTimer").start()
			get_node("RestTimer").start()
		if not is_on_floor() and not get_node("RestTimer").is_stopped() and !animplaying and in_range and !GameState.invincible:
			#print("wowow")
		
			anim.play("Attack")
			animplaying = true
			var fireball1 = fireball.instantiate()
			fireball1.position.x = position.x
			fireball1.position.y = position.y
			add_sibling(fireball1)
			await anim.animation_finished
			animplaying = false

			#print("ivy: ",position)
		#elif not is_on_floor() and !animplaying:
			#anim.play("Attack")
			#animplaying = true
			#var fireball1 = fireball.instantiate()
			#fireball1.position.x = position.x
			#fireball1.position.y = position.y
			#add_sibling(fireball1)
			#await anim.animation_finished
			#get_node("RestTimer").start()
		if not is_on_floor():
			velocity.y += gravity * delta
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
	get_node("CollisionDown").set_deferred("disabled", true)
	get_node("CollisionTop").set_deferred("disabled", true)
	get_node("CollisionRight").set_deferred("disabled", true)
	get_node("CollisionLeft").set_deferred("disabled", true)
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
		


func _on_attack_radius_body_entered(body):
	if body.name == "Player":
		in_range = true


func _on_attack_radius_body_exited(body):
	if body.name == "Player":
		in_range = false
