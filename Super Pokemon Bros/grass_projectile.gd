extends CharacterBody2D

const UPWARDS_VEL = -150
var SPEED = 100
var started = false
#var isstopped = false
var isdead = false
#var invincible = false
var nearby = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	add_to_group("enemy_projectiles")
	#SPEED *= GameState.direct
	position.y -= 15
	get_node("AnimatedSprite2D").play("grass_power_still")
	get_node("Timer").start()
	set_visible(0)
	await get_tree().create_timer(.25).timeout
	set_visible(1)
	velocity.y =UPWARDS_VEL
	started = true

func _physics_process(delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if isdead:
		#get_node("CollisionShape2D").set_defered("disabled", true)
		queue_free()
	#print("grass: ", position)
	if GameState.game_ended:
		#isstopped = true
		isdead = true
	# Add the gravity.
	if velocity.y == 0 and is_on_floor():
		#isstopped = true
		queue_free()
		#await get_tree().create_timer(.15).timeout
	elif velocity.y > 0:
		get_node("AnimatedSprite2D").play("grass_power_down")
	elif velocity.y < 0:
		get_node("AnimatedSprite2D").play("grass_power_up")
	if get_node("Timer").is_stopped():
		#set_collision_mask_value(4, true)
		#if not is_on_floor():
			#velocity.y += gravity * delta /2
		if is_on_floor():
			velocity.x = 0
		else:
			if get_node("CheckTimer").is_stopped():
				var direction = (GameState.player.position - Vector2(position.x + GameState.projectile_adjustment, position.y)).normalized()
				if direction.x > 0:
					#get_node("AnimatedSprite2D").flip_h = true 
					velocity.x = SPEED
				else:
					#get_node("AnimatedSprite2D").flip_h = false
					velocity.x = -SPEED
				#if position.x- 23 > GameState.player.position.x:
					#velocity.x = -SPEED*2
				#elif position.x - 23 < GameState.player.position.x:
					#velocity.x = SPEED*2
				get_node("CheckTimer").start()
			else:
				velocity.y = move_toward(velocity.y, randi_range(-UPWARDS_VEL, UPWARDS_VEL/2), 10)

	move_and_slide()
	#print("grasss")
	# Add the gravity.
	#velocity.y += gravity * delta
	#if velocity.y == 0 and is_on_floor():
		#get_node("AnimatedSprite2D").play("grass_power_still")
	#elif velocity.y > 0:
		#get_node("AnimatedSprite2D").play("grass_power_down")
	#elif velocity.y < 0:
		#get_node("AnimatedSprite2D").play("grass_power_up")
	##velocity.y = move_toward(velocity.y, randi_range(-UPWARDS_VEL, UPWARDS_VEL/2), 10)
	#if position.x > GameState.player.position.x:
		#velocity.x = -SPEED/5
	#elif position.x < GameState.player.position.x:
		#velocity.x = SPEED/5
	#if position.y < GameState.player.position.y:
		#velocity.y = UPWARDS_VEL/5
	#elif position.y > GameState.player.position.y:
		#velocity.y = UPWARDS_VEL/5
#
##
	#move_and_slide()

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
		
func _on_area_2d_body_entered(body):
	if body.name == "Player" and !GameState.invincible:
		if GameState.big and GameState.power == "":
			GameState.big = false
		elif GameState.big and GameState.power != "":
			GameState.big = true
			GameState.power = ""
		else:
			get_node("AnimatedSprite2D").queue_free()
			get_tree().call_group("player", "_death")
	elif started and !isdead:
		isdead = true
