extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	get_node("AnimatedSprite2D").play("water_power")
	get_node("Timer").start()
	set_visible(0)
	await get_tree().create_timer(.15).timeout
	set_visible(1)

func _physics_process(delta):
	if GameState.game_ended:
		queue_free()
	# Add the gravity.
		#await get_tree().create_timer(.15).timeout
	if get_node("Timer").is_stopped():
		set_collision_mask_value(4, true)
		if is_on_floor():
			velocity.y += gravity * delta
	else: 
		set_collision_mask_value(4, false)
		
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.power = "water"
		GameState.big = true
		queue_free()
