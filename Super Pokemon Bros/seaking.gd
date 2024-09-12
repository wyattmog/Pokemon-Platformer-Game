extends CharacterBody2D

var JUMP_VELOCITY = -100
var SPEED = 50.0
@onready var audio_player = get_node("SoundEffects")
var stomp_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/super-stomp.wav")
var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/kick.wav")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
var isdead = false
var jumped_on = false
var attack = false
var player_dir = 0
signal bounce_signal
var follow_timer = false
var animplaying = false
var attacked = false
var nearby
var start = false
var initial_position
signal enemy_death(body)

func _ready(): 
	initial_position = position
	add_to_group("enemies")
	anim.play("Idle")

func _physics_process(delta):
	print(follow_timer)
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if !isdead and start:
		var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters2D.create(position, GameState.player.position)
		var result = space_state.intersect_ray(query)["collider"].name == "Player"
		if !get_node("FollowTimer").is_stopped() and !follow_timer:
			follow_timer = true
		elif get_node("FollowTimer").is_stopped():
			follow_timer = false
	
		if attack and ((follow_timer and !get_node("FollowTimer").is_stopped()) or result):
			var direction = (GameState.player.position - self.position).normalized()
			if direction.x > 0:
				player_dir = 1
				get_node("AnimatedSprite2D").flip_h = true 
			else:
				player_dir = -1
				get_node("AnimatedSprite2D").flip_h = false
			#if !velocity.x or !velocity.y:
			anim.set_speed_scale(2)
			velocity.x = move_toward(velocity.x, SPEED * direction.x, 5.0)
			anim.play("Swim")
			velocity.y = move_toward(velocity.y, SPEED * direction.y, 3.0)
			if !follow_timer:
				get_node("FollowTimer").start()
		else:
			anim.set_speed_scale(1)
			position.x = move_toward(position.x, initial_position.x, 1)
			position.y = move_toward(position.y, initial_position.y, 1)
			if position.x < initial_position.x:
				get_node("AnimatedSprite2D").flip_h = true 
			elif position.x > initial_position.x:
				get_node("AnimatedSprite2D").flip_h = false
			if position == initial_position:
				anim.play("Idle")
	
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
	elif GameState.stomp_counter > 8:
		GameState._add_lives(1)
	GameState.stomp_counter += 1
	#chase = false
	if GameState.player.jumptype != "spin":
		audio_player.set_stream(death_sound)
		if GameState.player.velocity.y > 400:
			audio_player.set_pitch_scale(1.66)
		elif GameState.player.velocity.y > 300:
			audio_player.set_pitch_scale(1.33)
		else:
			audio_player.set_pitch_scale(1)
	else:
		audio_player.set_stream(stomp_sound)
	audio_player.play()
	get_node("PlayerHitbox/CollisionShape2D").set_deferred("disabled", true)
	get_node("CollisionDown").set_deferred("disabled", true)
	get_node("CollisionTop").set_deferred("disabled", true)
	get_node("CollisionRight").set_deferred("disabled", true)
	get_node("CollisionLeft").set_deferred("disabled", true)
	emit_signal("enemy_death", get_path())
	anim.play("Death")
	if !attacked:
		get_tree().call_group("player", "_spawn_kick")
		emit_signal("bounce_signal")
	await get_tree().create_timer(0.25).timeout
	get_node("AnimatedSprite2D").set_visible(false)	
	if GameState.player.jumptype == "spin":
		await get_tree().create_timer(0.40).timeout
	self.queue_free()

func _on_player_grass_attack():
	attacked = true
	jumped_on = false
	if nearby:
		isdead = true
		death()

func _on_player_grass_attack_ended():
	attacked = false


func _on_player_hitbox_body_entered(body):
	if body.is_in_group("projectiles") and not isdead:
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
			get_tree().call_group("player", "_death")



func _on_player_detection_body_entered(body):
	if body.name == "Player":
		start = true


func _on_attack_radius_body_entered(body):
	if body.name == "Player":
		attack = true


func _on_attack_radius_body_exited(body):
	if body.name == "Player":
		attack = false
