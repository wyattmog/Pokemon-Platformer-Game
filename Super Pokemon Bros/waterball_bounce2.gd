extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction 
var water_particle = preload("res://water_particles.tscn")
@onready var audio_player = get_node("SoundEffects")
var splash_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/water-gun_xKgwgdvI.wav")
var bounce2 = preload("res://waterball_bounce2.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var has_split = false
var bounce_count = 0
#var max_bounces = 3
func _ready():
	add_to_group("projectiles")
	audio_player.set_stream(splash_sound)
	audio_player.play()
	#GameState.split = false
	#get_node("AnimatedSprite2D2").set_visible(0)
	#get_node("AnimatedSprite2D3").set_visible(0)
	#get_node("AnimatedSprite2D3").play("waterball")")
	get_node("AnimatedSprite2D").play("waterball_bounce2")
	#var new_dust = waterball.instantiate()
	#new_dust.position.x = position.x
	#new_dust.position.y = position.y + 14
	#add_sibling(new_dust)
	#if GameState.split:
		#GameState.split = false
	#else:
		#GameState.split = true
	
func _physics_process(delta):
	if get_node("WaterTimer").is_stopped():
		_spawn_particles()
	if !get_node("AnimatedSprite2D").is_playing():
		queue_free()
	# Add the gravity
	if velocity.x > 0:
		direction = 1
	elif velocity.x < 0:
		direction = -1
	if !velocity.x and direction == 1:
		velocity.x = SPEED * -1
	elif !velocity.x and direction == -1:
		velocity.x = SPEED
		
	#if not is_on_floor() and GameState.split:
		#await get_tree().create_timer(.15).timeout
		#GameState.split = false
	if not is_on_floor():
		velocity.y += gravity * delta
		get_node("CollisionShape2D").set_disabled(true)
		#has_split = false
	#if is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#if !has_split:
			#has_split = true
		#if !GameState.split:
			#GameState.split = true
			#split_water_ball()
			#set_physics_process(false)
			#queue_free()
			#await get_tree().create_timer(.15).timeout
			#set_physics_process(true)
			#has_split = false
		#GameState.split = true
		#var waterball_1 = preload("res://water_ball.tscn").instantiate()
		#var waterball_2 = preload("res://water_ball.tscn").instantiate()
		#waterball_1.position.x = move_toward(position.x, position.x - 100, 10)
		#waterball_1.position.y = position.y
		#waterball_2.position.x = move_toward(position.x, position.x + 100, 10)
		#waterball_2.position.y = position.y
		#self.queue_free()
		#add_sibling(waterball_1)
		#add_sibling(waterball_2)
		#self.queue_free()

	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
	
#func split_water_ball():
	#var waterball_1 = waterball.instantiate()
	#var waterball_2 = waterball.instantiate()
	#
	#waterball_1.position = position + Vector2(-10, 0)
	#waterball_2.position = position + Vector2(10, 0)
	#
	## Adjust direction and velocity for droplets if needed
	#waterball_1.velocity.x = SPEED * -1
	#waterball_2.velocity.x = SPEED * 1
	#
	#get_parent().add_child(waterball_1)
	#get_parent().add_child(waterball_2)
func _spawn_particles():
	#if not get_node("FireTimer").is_stopped():
		#return
	var water_particles = water_particle.instantiate()
	water_particles.position.x = position.x
	water_particles.position.y = position.y
	add_sibling(water_particles)
	get_node("WaterTimer").start()
func _on_area_2d_body_entered(body):
	if body.name == "Charmander":
		queue_free()
		
		
