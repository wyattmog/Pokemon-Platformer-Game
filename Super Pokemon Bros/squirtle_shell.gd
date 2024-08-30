extends CharacterBody2D

var SPEED = 150
var stationary = false
var direction
#var invincible = false
var isdead = false
var nearby = false
var started = false
var stop_func = false
var jumptype = ""
@onready var anim = get_node("AnimationPlayer")
@onready var audio_player = get_node("SoundEffects")

var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/kick.wav")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready(): 
	#add_to_group("enemy_projectiles")
	#add_to_group("projectiles")
	add_to_group("shell_projectile")
	remove_from_group("projectiles")
	anim.play("shell_idle")
	await get_tree().create_timer(.15).timeout
	started = true 
	stationary = true
	#set_absorbent(false)
func _physics_process(delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if stationary:
		add_to_group("enemy_projectiles")
		remove_from_group("projectiles")
	else: 
		add_to_group("projectiles")
		remove_from_group("enemy_projectiles")
	# Add the gravity.
	#print(velocity.x)
	#if GameState.game_ended:
		#queue_free()X
	if isdead and not stop_func:
		stop_func = true
		velocity.y = -100
		death()
	if not is_on_floor():
		velocity.y += gravity * delta
	#else:
		#velocity.y = 0
	if started and not stationary and !isdead:
		if velocity.x > 0:
			direction = 1
		elif velocity.x < 0:
			direction = -1
		if !velocity.x and direction == 1:
			velocity.x = SPEED * -1
		elif !velocity.x and direction == -1:
			velocity.x = SPEED
	if isdead and jumptype == "spin":
		velocity.x = 0
		velocity.y = 0
	#if get_node("Timer").is_stopped():
		#set_z_index(2)
		#set_collision_mask_value(4, true)
		#set_z_index(2)
		#velocity.x = SPEED
		#if not is_on_floor():
			#velocity.y += gravity * delta
	#else: 
		#set_collision_mask_value(4, false)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
func death():
	#chase = false
	audio_player.set_stream(death_sound)
	if GameState.player.velocity.y > 400:
		audio_player.set_pitch_scale(1.66)
	elif GameState.player.velocity.y > 300:
		audio_player.set_pitch_scale(1.33)
	else:
		audio_player.set_pitch_scale(1)
	audio_player.play()
	#get_node("PlayerHitbox/CollisionShape2D").set_deferred("disabled", true)
	#get_node("CollisionDown").set_deferred("disabled", true)
	#get_node("CollisionTop").set_deferred("disabled", true)
	#get_node("CollisionRight").set_deferred("disabled", true)
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("Shell2D/CollisionShape2D").set_deferred("disabled", true)
	emit_signal("enemy_death", get_path())
	if jumptype == "spin":
		anim.play("Death")
		await get_tree().create_timer(.25).timeout
	else:
		#get_node("AnimatedSprite2D").play("death")
		await get_tree().create_timer(2.0).timeout
	self.queue_free()
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
		
func is_above():
	return GameState.player.position.y < position.y +90 and GameState.player.velocity.y > 0
	#
#func _on_area_2d_body_entered(body):
	#if body.is_in_group("projectiles") and not isdead:
		#isdead=true



func _on_area_2d_area_entered(area):
	if area.name == "PlayerArea" and started:
		#print(area.name)
		if stationary:
			#add_to_group("enemy_projectiles")
			#remove_from_group("projectiles")
			#print("wpw")
			#print("wpw")
			audio_player.set_stream(death_sound)
			if GameState.player.velocity.y > 400:
				audio_player.set_pitch_scale(1.66)
			elif GameState.player.velocity.y > 300:
				audio_player.set_pitch_scale(1.33)
			else:
				audio_player.set_pitch_scale(1)
			audio_player.play()
			if is_above() or velocity.x == 0:
				if is_above() and GameState.player.jumptype != "spin":
					get_tree().call_group("player", "_spawn_kick")
					get_tree().call_group("player", "_on_bounce_signal")
					print("wow")
				elif is_above() and GameState.player.jumptype == "spin":
					isdead = true
					jumptype = "spin"
					get_tree().call_group("player", "_spawn_kick")
					get_tree().call_group("player", "_on_bounce_signal")
					death()
				anim.play("shell_moving")
				direction = GameState.direct
				#position.x += direction*10
				velocity.x = SPEED * direction
				#velocity.y = 0
				stationary = false
			elif !GameState.invincible:
				if GameState.big and GameState.power == "":
					GameState.big = false
				elif GameState.big and GameState.power != "":
					GameState.big = true
					GameState.power = ""
				else:
					self.queue_free()
					get_tree().change_scene_to_file("res://main.tscn")
		else:
			#add_to_group("projectiles")
			#remove_from_group("enemy_projectiles")
			if is_above() and GameState.player.jumptype != "spin":
				#print("jumped")
				get_tree().call_group("player", "_spawn_kick")
				get_tree().call_group("player", "_on_bounce_signal")
				anim.play("shell_idle")
				velocity.x = 0
				#velocity.y = 0
				stationary = true
				audio_player.set_stream(death_sound)
				if GameState.player.velocity.y > 400:
					audio_player.set_pitch_scale(1.66)
				elif GameState.player.velocity.y > 300:
					audio_player.set_pitch_scale(1.33)
				else:
					audio_player.set_pitch_scale(1)
				audio_player.play()
			elif is_above() and GameState.player.jumptype == "spin":
				isdead = true
				jumptype = "spin"
				get_tree().call_group("player", "_spawn_kick")
				get_tree().call_group("player", "_on_bounce_signal")
				death()
			elif !GameState.invincible:
				if GameState.big and GameState.power == "":
					GameState.big = false
				elif GameState.big and GameState.power != "":
					GameState.big = true
					GameState.power = ""
				else:
					#get_node("AnimatedSprite2D").queue_free()
					get_tree().call_group("player", "_death")
	#elif area.name == "Shell2D" and not isdead and not stationary and started:
		#isdead = true
	elif area.name == "Shell2D" and not isdead and stationary and started:
		isdead = true


func _on_shell_2d_body_entered(body):
	if body.is_in_group("projectiles") and !body.is_in_group("shell_projectile") and not isdead:
		death()
		isdead=true
	elif body.is_in_group("projectiles") and body.is_in_group("shell_projectile") and abs(body.velocity.x) > 0:
		death()
		isdead=true
		
	#elif body.is_in_group("shell_projectile") and body.is_in_group("projectiles") and !stationary:
		#death()
		#isdead=true
