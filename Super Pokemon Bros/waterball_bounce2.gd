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
var bounce_count = 0
func _ready():
	add_to_group("projectiles")
	audio_player.set_stream(splash_sound)
	audio_player.play()
	get_node("AnimatedSprite2D").play("waterball_bounce2")
	
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
		

	if not is_on_floor():
		velocity.y += gravity * delta
		get_node("CollisionShape2D").set_disabled(true)


	move_and_slide()

func _spawn_particles():
	var water_particles = water_particle.instantiate()
	water_particles.position.x = position.x
	water_particles.position.y = position.y
	add_sibling(water_particles)
	get_node("WaterTimer").start()
func _on_area_2d_body_entered(body):
	if body.name == "Charmander":
		queue_free()
		
		
