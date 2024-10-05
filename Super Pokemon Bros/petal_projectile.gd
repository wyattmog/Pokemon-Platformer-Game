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
	get_node("AnimatedSprite2D").play("petal_idle")
	get_node("Timer").start()
	set_visible(0)
	await get_tree().create_timer(.25).timeout
	set_visible(1)
	velocity.y =randi_range(UPWARDS_VEL, UPWARDS_VEL*1.5)
	velocity.x =randi_range(-SPEED*3, SPEED*3)
	started = true
	await get_tree().create_timer(.25).timeout

func _physics_process(_delta):
	if GameState.invincible:
		set_collision_mask_value(1, false)
	else:
		set_collision_mask_value(1, true)
	if isdead:
		queue_free()
	if GameState.game_ended:
		isdead = true
	if velocity.y == 0 and is_on_floor():
		queue_free()
	if get_node("Timer").is_stopped():
		if is_on_floor():
			velocity.x = 0
		else:
			if get_node("CheckTimer").is_stopped():
				var direction = (GameState.player.position - Vector2(position.x + GameState.projectile_adjustment, position.y)).normalized()
				if direction.x > 0:
					velocity.x = SPEED
				else:
					velocity.x = -SPEED
				get_node("CheckTimer").set_wait_time(randi_range(1, 4))
				get_node("CheckTimer").start()
			else:
				velocity.y = move_toward(velocity.y, randi_range(-UPWARDS_VEL, UPWARDS_VEL/2), 10)

	move_and_slide()

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
