extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction
var started = false
var isdead = false
var nearby = false
@onready var fire_particle = preload("res://fire_particles.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	add_to_group("enemy_projectiles")
	var direction = (GameState.player.position - Vector2(position.x + GameState.projectile_adjustment, position.y)).normalized()
	if direction.x > 0:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED 
	get_node("AnimatedSprite2D").play("fireball")
	get_node("LifeTimer").start()
	await get_tree().create_timer(.15).timeout
	started = true
	
func _physics_process(delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if get_node("FireTimer").is_stopped():
		_spawn_particles()
	if get_node("LifeTimer").is_stopped():
		queue_free()
	if isdead:
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
		velocity.y = JUMP_VELOCITY

	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
	#
#func invincible_start():
	#invincible = true
	#set_collision_mask_value(1, false)
	#
#func invincible_end():
	#invincible = false
	#set_collision_mask_value(1, true)
	
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
	#if not get_node("FireTimer").is_stopped():
		#return
	var fire_particles = fire_particle.instantiate()
	fire_particles.position.x = position.x
	fire_particles.position.y = position.y
	add_sibling(fire_particles)
	get_node("FireTimer").start()

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
		
