extends CharacterBody2D

var SPEED = 150
var stationary = false
var direction
#var invincible = false
var isdead = false
var nearby = false
var started = false
var stop_func = false
var timer_started = false
var score_gate = false
var kicked = false
var jumptype = ""
signal enemy_death(body)
@onready var anim = get_node("AnimationPlayer")
@onready var audio_player = get_node("SoundEffects")
var stomp_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/super-stomp.wav")
var death_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/kick.wav")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready(): 
	add_to_group("shell_projectile")
	remove_from_group("projectiles")
	anim.play("shell_idle")
	await get_tree().create_timer(.15).timeout
	started = true 
	stationary = true
func _physics_process(delta):
	if timer_started and get_node("ShellKickTimer").is_stopped() and kicked:
		GameState.shellkicked = false
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
	if isdead and not stop_func:
		stop_func = true
		velocity.y = -100
		death()
	if not is_on_floor():
		velocity.y += gravity * delta
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

	move_and_slide()
func _start_timer():
	if kicked:
		timer_started = true
		get_node("ShellKickTimer").start()
func death():
	if GameState.stomp_counter == 0:
		GameState._give_score(100)
	elif GameState.stomp_counter == 1:
		GameState._give_score(200)
	elif GameState.stomp_counter == 2:
		GameState._give_score(400)
	elif GameState.stomp_counter == 3:
		GameState._give_score(500)
	elif GameState.stomp_counter == 4:
		GameState._give_score(800)
	elif GameState.stomp_counter == 5:
		GameState._give_score(1000)
	elif GameState.stomp_counter == 6:
		GameState._give_score(2000)
	elif GameState.stomp_counter == 7:
		GameState._give_score(4000)
	elif GameState.stomp_counter == 7:
		GameState._give_score(5000)
	elif GameState.stomp_counter == 8:
		GameState._give_score(8000)
	GameState.stomp_counter += 1
	#chase = false
	if GameState.player.jumptype != "spin":
		audio_player.set_stream(death_sound)
		if GameState.player.velocity.y > 400:
			audio_player.set_pitch_scale(1.66)
		elif GameState.player.velocity.y > 300:
			audio_player.set_pitch_scale(1.33)
		else:
			audio_player.set_pitch_scale(1)
	else:
		audio_player.set_stream(stomp_sound)
	audio_player.play()
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("Shell2D/CollisionShape2D").set_deferred("disabled", true)
	emit_signal("enemy_death", get_path())
	if jumptype == "spin":
		anim.play("Death")
		await get_tree().create_timer(.25).timeout
	else:
		await get_tree().create_timer(2.0).timeout
	get_node("AnimatedSprite2D").set_visible(false)
	if GameState.player.jumptype == "spin":
		await get_tree().create_timer(0.40).timeout
	self.queue_free()
	
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
	return GameState.player.position.y + 10 < position.y and (((GameState.player.velocity.y > 0 || GameState.player.bounce)) || (GameState.player.jumptype == "spin" and GameState.player.velocity.y < 0) || (GameState.player.velocity.y == 0))

func _on_area_2d_area_entered(area):
	if area.name == "PlayerArea" and started:
		if stationary:
			kicked = true
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
				elif is_above() and GameState.player.jumptype == "spin":
					isdead = true
					jumptype = "spin"
					get_tree().call_group("player", "_spawn_kick")
					get_tree().call_group("player", "_on_bounce_signal")
					death()
				anim.play("shell_moving")
				direction = GameState.direct
				if not score_gate:
					GameState._give_score(400)
					score_gate = true
				velocity.x = SPEED * direction
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
			if is_above() and GameState.player.jumptype != "spin":
				get_tree().call_group("player", "_spawn_kick")
				get_tree().call_group("player", "_on_bounce_signal")
				anim.play("shell_idle")
				kicked = false
				velocity.x = 0
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
					get_tree().call_group("player", "_death")
	elif area.name == "Shell2D" and not isdead and stationary and started:
		isdead = true


func _on_shell_2d_body_entered(body):
	if body.is_in_group("projectiles") and !body.is_in_group("shell_projectile") and not isdead:
		death()
		isdead=true
	elif body.is_in_group("projectiles") and body.is_in_group("shell_projectile") and abs(body.velocity.x) > 0:
		death()
		if body.is_in_group("shell_projectile"):
			GameState.shellkicked = true
			get_tree().call_group("shell_projectile", "_start_timer")
		isdead=true

