extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction
var water_particle = preload("res://water_particles.tscn")
var water_bounce1 = preload("res://waterball_bounce1.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var has_split = false
var started = false
var bounce_count = 0
#var max_bounces = 3
func _ready():
	add_to_group("projectiles")

	velocity.x = SPEED * GameState.direct

	get_node("AnimatedSprite2D").play("waterball_bounce1")

	
func _physics_process(delta):
	if get_node("WaterTimer").is_stopped():
		_spawn_particles()

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

	if is_on_floor():
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
		
		
