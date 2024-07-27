
extends CharacterBody2D

var SPEED = 50
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player 
#var chase = false
var isdead = false
signal bounce_signal
var attacked
var nearby
signal enemy_death(body)

func _ready(): 
	get_node("AnimatedSprite2D").play("Idle")
	velocity.x = SPEED

func _physics_process(delta):
	#print(attacked)
	 #Add the gravity.
	velocity.y += gravity * delta
	if !isdead:
		get_node("AnimatedSprite2D").play("Walk")
		velocity.x = -SPEED
	else: 
		velocity.x = 0
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
	
	move_and_slide()
	
func _on_player_detection_body_entered(body):
	if body.name == "Player":
		nearby = true
		print("noo")
		#print("entered")

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		nearby = false
		#print("exited")
		
func _on_player_death_body_entered(body):
	if body.name == "Player":
		death()
		isdead=true

func _on_player_collision_body_entered(body):
	if body.name == "Player":
		get_node("AnimatedSprite2D").queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
		
func death():
	#chase = false
	get_node("PlayerCollision/CollisionPolygon2D").disabled = true
	get_node("PlayerDeath/CollisionPolygon2D").disabled = true
	emit_signal("enemy_death", get_path())
	get_node("AnimatedSprite2D").play("Death")
	if !attacked:
		emit_signal("bounce_signal")
	await get_node("AnimatedSprite2D").animation_finished
	self.queue_free()
	
	
func _on_player_grass_attack():
	attacked = true
	if nearby:
		#get_node("PlayerCollision/CollisionPolygon2D").disabled = true
		#get_node("PlayerDeath/CollisionPolygon2D").disabled = true
		#emit_signal("enemy_death", get_path())
		isdead = true
		death()
		



func _on_player_grass_attack_ended():
	attacked = false
