extends CharacterBody2D


var SPEED
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var chase = false
#var player
var isdead = false
signal bounce_signal
var attacked = false
var nearby
#var collided = false
var invincible = false
signal enemy_death(body)

func _ready(): 
	add_to_group("enemies")
	get_node("AnimatedSprite2D").play("Idle")
	velocity.x = SPEED

func _physics_process(delta):
	 #Add the gravity.
	velocity.y += gravity * delta
	if !isdead:
		get_node("AnimatedSprite2D").play("Walk")
		velocity.x = -SPEED
	else: 
		velocity.x = 0
		velocity.y = 0
	#if chase == true:
		#if !isdead:
			#get_node("AnimatedSprite2D").play("Walk")
		#player = get_node("../../Player/Player")
		#var direction = (player.position - self.position).normalized()
		#if direction.x > 0:
			#get_node("AnimatedSprite2D").flip_h = true 
		#else:
			#get_node("AnimatedSprite2D").flip_h = false
		#if !isdead:
			#velocity.x = direction.x * SPEED
	#else:
		#velocity.x = 0
	#print(invincible)
	
	move_and_slide()
	
func _on_leaf_detection_body_entered(body):
	if body.name == "Player" and !isdead:
		nearby = true

func _on_leaf_detection_body_exited(body):
	if body.name == "Player":
		nearby = false
		
func death():
	get_node("PlayerHitbox/CollisionShape2D").set_deferred("disabled", true)
	get_node("CollisionDown").set_deferred("disabled", true)
	get_node("CollisionTop").set_deferred("disabled", true)
	get_node("CollisionRight").set_deferred("disabled", true)
	get_node("CollisionLeft").set_deferred("disabled", true)

	emit_signal("enemy_death", get_path())
	get_node("AnimatedSprite2D").play("Death")
	if !attacked:
		emit_signal("bounce_signal")
	await get_node("AnimatedSprite2D").animation_finished
	self.queue_free()
	
	
func invincible_start():
	invincible = true
	set_collision_mask_value(1, false)
	
func invincible_end():
	invincible = false
	set_collision_mask_value(1, true)

func _on_player_grass_attack():
	attacked = true
	if nearby:
		isdead = true
		death()

func _on_player_grass_attack_ended():
	attacked = false

func is_above():
	return GameState.player.position.y < position.y/2 +90 and GameState.player.velocity.y > 0


func _on_player_hitbox_body_entered(body):
	print(body.name)
	if body.name == "Player" and not isdead and !invincible and is_above():
		death()
		isdead=true
	elif body.is_in_group("projectiles") and not isdead:
		death()
		isdead=true
	elif body.is_in_group("projectiles") and not isdead:
		death()
		isdead=true
	elif body.name == "Player" and !isdead and !invincible:
		if GameState.big and GameState.power == "":
			GameState.big = false
		elif GameState.big and GameState.power != "":
			GameState.big = true
			GameState.power = ""
		else:
			get_node("AnimatedSprite2D").queue_free()
			get_tree().change_scene_to_file("res://main.tscn")
			

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		pass
