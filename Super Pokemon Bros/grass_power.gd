extends CharacterBody2D
const UPWARDS_VEL = -100
var SPEED = 50
var curr_world
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	SPEED *= GameState.direct
	get_node("AnimatedSprite2D").play("grass_power_still")
	get_node("Timer").start()
	set_visible(0)
	curr_world = GameState.curr_world
	await get_tree().create_timer(.15).timeout
	set_visible(1)
	velocity.y =UPWARDS_VEL

func _physics_process(delta):
	if GameState.game_ended || curr_world != GameState.curr_world:
		queue_free()
	if velocity.y == 0 and is_on_floor():
		get_node("AnimatedSprite2D").play("grass_power_still")
	elif velocity.y > 0:
		get_node("AnimatedSprite2D").play("grass_power_down")
	elif velocity.y < 0:
		get_node("AnimatedSprite2D").play("grass_power_up")
	if get_node("Timer").is_stopped():
		set_z_index(2)
		set_collision_mask_value(4, true)
		if is_on_floor():
			velocity.y += gravity * delta
			velocity.x = 0
		else:
			velocity.y = move_toward(velocity.y, randi_range(-UPWARDS_VEL, UPWARDS_VEL/2), 10)
			velocity.x = SPEED
	else: 
		set_collision_mask_value(4, false)

	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.power = "grass"
		GameState._give_score(1000)
		GameState.big = true
		queue_free()
