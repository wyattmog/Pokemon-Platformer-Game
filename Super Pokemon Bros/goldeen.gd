extends CharacterBody2D

var JUMP_VELOCITY = -100
var SPEED = 50
@onready var audio_player = get_node("SoundEffects")
var stomp_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/super-stomp.wav")
var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/kick.wav")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var BubbleScene = preload("res://bubble.tscn")
@onready var anim = get_node("AnimationPlayer")
var isdead = false
var jumped_on = false
signal bounce_signal
var attacked = false
var nearby
var start = false
signal enemy_death(body)

func _ready(): 
	add_to_group("enemies")
	anim.play("Swim")
	velocity.x = SPEED

func _physics_process(delta):
	if get_node("BubbleTimer").is_stopped():
		_spawn_bubble()
		get_node("BubbleTimer").set_wait_time(randf_range(.5,1))
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	 #Add the gravity.
	if !isdead and start:
		anim.play("Swim")
		velocity.x = -SPEED
		velocity.y = move_toward(velocity.y, randf_range(-5,5), 5)
	else: 
		velocity.x = 0
		velocity.y = 0
	
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
	scale = Vector2(2,2)
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

func _spawn_bubble():
	if not get_node("BubbleTimer").is_stopped():
		return
	var BubbleScene = BubbleScene.instantiate()
	BubbleScene.position.x = position.x
	BubbleScene.position.y = position.y - 5
	add_sibling(BubbleScene)
	get_node("BubbleTimer").start()

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		start = true

