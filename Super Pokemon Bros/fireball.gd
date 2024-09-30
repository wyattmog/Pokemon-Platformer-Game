extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var fire_particle = preload("res://fire_particles.tscn")
func _ready():
	add_to_group("projectiles")
	velocity.x = SPEED * GameState.direct
	get_node("AnimatedSprite2D").play("fireball")
	get_node("LifeTimer").start()
	
func _physics_process(delta):
	if get_node("FireTimer").is_stopped():
		_spawn_particles()
	if get_node("LifeTimer").is_stopped():
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
		
	else:
		if GameState.water_gravity:
			velocity.y = JUMP_VELOCITY/3
		else:
			velocity.y = JUMP_VELOCITY


	move_and_slide()
	

func _spawn_particles():
	var fire_particles = fire_particle.instantiate()
	fire_particles.position.x = position.x
	fire_particles.position.y = position.y
	add_sibling(fire_particles)
	get_node("FireTimer").start()

		
		
		
