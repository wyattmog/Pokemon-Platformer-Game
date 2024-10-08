extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var audio_player = get_node("SoundEffects")
var splash_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/water-gun_xKgwgdvI.wav")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var water_particle = preload("res://water_particles.tscn")
var bounce2 = preload("res://enemy_waterball_bounce2.tscn")
var bounce_count = 0
var isdead = false
var nearby
var started = false
func _ready():
	add_to_group("enemy_projectiles")
	audio_player.set_stream(splash_sound)
	audio_player.play()

	get_node("AnimatedSprite2D").play("waterball_bounce1")
	await get_tree().create_timer(.15).timeout
	started = true
	
func _physics_process(delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if isdead:
		queue_free()
	if !get_node("AnimatedSprite2D").is_playing():
		isdead = true
	if get_node("WaterTimer").is_stopped():
		_spawn_particles()
	# Add the gravity
	if velocity.x > 0:
		direction = 1
	elif velocity.x < 0:
		direction = -1
	if !velocity.x and direction == 1:
		velocity.x = SPEED * -1
	elif !velocity.x and direction == -1:
		velocity.x = SPEED
	if not is_on_floor():
		velocity.y += gravity * delta
		started = true
	if is_on_floor() and started:
		var bounce2_1 = bounce2.instantiate()
		var bounce2_2 = bounce2.instantiate()
		bounce2_1.position = position
		bounce2_2.position = position
		bounce2_1.velocity.x = velocity.x
		bounce2_2.velocity.x = velocity.x
		bounce2_1.velocity.y = JUMP_VELOCITY
		bounce2_2.velocity.y = JUMP_VELOCITY
		bounce2_1.position.x += randi_range(1,20)
		bounce2_2.position.x += randi_range(-1,-20)
		bounce2_1.position.y += randi_range(-5,5)
		bounce2_2.position.y += randi_range(-5,5)
		get_parent().add_child(bounce2_1)
		get_parent().add_child(bounce2_2)
		queue_free()

	move_and_slide()
	
	
func _on_leaf_detection_body_entered(body):
	if body.name == "Player" and !isdead:
		nearby = true

func _on_leaf_detection_body_exited(body):
	if body.name == "Player":
		nearby = false
		
func _on_player_grass_attack():
	if nearby:
		isdead = true
func _spawn_particles():
	var water_particles = water_particle.instantiate()
	water_particles.position.x = position.x
	water_particles.position.y = position.y
	add_sibling(water_particles)
	get_node("WaterTimer").start()
	
func _on_area_2d_body_entered(body):
	if body.name == "Player" and !GameState.invincible:
		if GameState.big and GameState.power == "":
			GameState.big = false
		elif GameState.big and GameState.power != "":
			GameState.big = true
			GameState.power = ""
		else:
			get_tree().call_group("player", "_death")
	elif started and !isdead:
		isdead = true
		
