extends CharacterBody2D

var SPEED = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready(): 
	SPEED *= GameState.direct
	get_node("AnimatedSprite2D").play("mushroom_power")
	get_node("Timer").start()
	set_visible(0)
	await get_tree().create_timer(.15).timeout
	set_visible(1)
func _physics_process(delta):
	# Add the gravity.
	#print(velocity.x)
	#if GameState.game_ended:
		#queue_free()
	
	if get_node("Timer").is_stopped():
		set_collision_mask_value(4, true)
		set_z_index(2)
		velocity.x = SPEED
		if not is_on_floor():
			velocity.y += gravity * delta
	else: 
		set_collision_mask_value(4, false)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.big = true
		queue_free()
