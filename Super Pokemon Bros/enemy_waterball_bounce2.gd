extends CharacterBody2D
var SPEED = 150.0
const JUMP_VELOCITY = -200.0
var direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var has_split = false
@onready var audio_player = get_node("SoundEffects")
var splash_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/water-gun_xKgwgdvI.wav")
var water_particle = preload("res://water_particles.tscn")
var bounce_count = 0
var invincible = false
var isdead = false
var nearby
var started = false
#var max_bounces = 3
func _ready():
	add_to_group("enemy_projectiles")
	audio_player.set_stream(splash_sound)
	audio_player.play()
	#GameState.split = false
	#get_node("AnimatedSprite2D2").set_visible(0)
	#get_node("AnimatedSprite2D3").set_visible(0)
	#velocity.x = SPEED * GameState.direct
	#get_node("AnimatedSprite2D3").play("waterball")
	get_node("AnimatedSprite2D").play("waterball_bounce2")
	#var new_dust = waterball.instantiate()
	#new_dust.position.x = position.x
	#new_dust.position.y = position.y + 14
	#add_sibling(new_dust)
	#if GameState.split:
		#GameState.split = false
	#else:
		#GameState.split = true
	await get_tree().create_timer(.15).timeout
	started = true
	
func _physics_process(delta):
	if isdead:
		queue_free()
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
	#if is_on_floor():
		#velocity.y += gravity * delta
		#get_node("CollisionShape2D").set_disabled(true)
		#bounce_count += 1
		#var node1
		#var node2
		#var node3
		#var node4
		##print(get_node("AnimatedSprite2D").position)
		#if bounce_count == 1: 
			##scale = Vector2(.75,.75)
			#velocity.y = JUMP_VELOCITY
			#node1 = randi_range(1,20)
			#node2 = randi_range(1,20)
			#node3 = randi_range(-1,-20)
			#node4 = randi_range(-1,-20)
			#get_node("AnimatedSprite2D").position.x += node1
			#get_node("AnimatedSprite2D3").position.x += node1
			#get_node("AnimatedSprite2D2").position.x += node3
			#get_node("AnimatedSprite2D4").position.x += node3
			#get_node("Area2D/CollisionShape2D").position.x += node1
			#get_node("Area2D/CollisionShape2D3").position.x += node1
			#get_node("Area2D/CollisionShape2D2").position.x += node3
			#get_node("Area2D/CollisionShape2D4").position.x += node3
		#elif bounce_count == 2:
			#scale = Vector2(.75,.75)
			#velocity.y = JUMP_VELOCITY/1.5
			#node1 = randi_range(1,10)
			#node2 = randi_range(1,10)
			#node3 = randi_range(-1,-10)
			#node4 = randi_range(-1,-10)
			#get_node("AnimatedSprite2D").position.x += node1
			#get_node("AnimatedSprite2D2").position.x += node2
			#get_node("AnimatedSprite2D3").position.x += node3
			#get_node("AnimatedSprite2D4").position.x += node4
			#get_node("Area2D/CollisionShape2D").position.x +=node1
			#get_node("Area2D/CollisionShape2D3").position.x += node3
			#get_node("Area2D/CollisionShape2D2").position.x += node2
			#get_node("Area2D/CollisionShape2D4").position.x += node4
		#else:
			#scale = Vector2(.375,.375)
			#velocity.y = 0
			##self.set_collision_layer_value(0, true)
			#get_node("CollisionShape2D").set_disabled(true)
			#get_node("Area2D/CollisionShape2D").set_disabled(true)
			#get_node("Area2D/CollisionShape2D3").set_disabled(true)
			#get_node("Area2D/CollisionShape2D2").set_disabled(true)
			#get_node("Area2D/CollisionShape2D4").set_disabled(true)

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
func invincible_start():
	invincible = true
	set_collision_mask_value(1, false)
	
func invincible_end():
	invincible = false
	set_collision_mask_value(1, true)
	
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
	var water_particles = water_particle.instantiate()
	water_particles.position.x = position.x
	water_particles.position.y = position.y
	add_sibling(water_particles)
	get_node("WaterTimer").start()
func _on_area_2d_body_entered(body):
	if body.name == "Player" and !invincible:
		if GameState.big and GameState.power == "":
			GameState.big = false
		elif GameState.big and GameState.power != "":
			GameState.big = true
			GameState.power = ""
		else:
			#get_node("AnimatedSprite2D").queue_free()
			get_tree().call_group("player", "_death")
	elif started and !isdead:
		isdead = true
		print("dead")
		
