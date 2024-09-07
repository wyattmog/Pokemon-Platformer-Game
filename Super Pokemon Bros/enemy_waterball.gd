extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
var water_bounce1 = preload("res://enemy_waterball_bounce1.tscn")
@onready var audio_player = get_node("SoundEffects")
var splash_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/water-gun_xKgwgdvI.wav")
var water_particle = preload("res://water_particles.tscn")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var bounce_count = 0
var isdead = false
var nearby
var started = false
func _ready():
	add_to_group("enemy_projectiles")
	var direction = (GameState.player.position - Vector2(position.x + GameState.projectile_adjustment, position.y)).normalized()
	if direction.x > 0:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED 
	get_node("AnimatedSprite2D").play("waterball_bounce1")
	await get_tree().create_timer(.15).timeout
	started = true
	
func _physics_process(delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if get_node("WaterTimer").is_stopped():
		_spawn_particles()
	if isdead:
		queue_free()
	if !get_node("AnimatedSprite2D").is_playing():
		isdead = true
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

	if is_on_floor() and started:
		var bounce1_1 = water_bounce1.instantiate()
		var bounce1_2 = water_bounce1.instantiate()
		bounce1_1.position = position
		bounce1_2.position = position
		bounce1_1.velocity.x = velocity.x
		bounce1_2.velocity.x = velocity.x
		bounce1_1.velocity.y = JUMP_VELOCITY
		bounce1_2.velocity.y = JUMP_VELOCITY
		bounce1_1.position.x += randi_range(1,20)
		bounce1_2.position.x += randi_range(-1,-20)
		bounce1_1.position.y += randi_range(-5,5)
		bounce1_2.position.y += randi_range(-5,5)
		get_parent().add_child(bounce1_1)
		get_parent().add_child(bounce1_2)
		queue_free()

	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

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
		print("dead")
		
