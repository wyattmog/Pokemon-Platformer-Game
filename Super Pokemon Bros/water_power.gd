extends CharacterBody2D
var curr_world
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	get_node("AnimatedSprite2D").play("water_power")
	get_node("Timer").start()
	set_visible(0)
	curr_world = GameState.curr_world
	await get_tree().create_timer(.15).timeout
	set_visible(1)

func _physics_process(delta):
	if GameState.game_ended || curr_world != GameState.curr_world:
		queue_free()
	# Add the gravity.
	if get_node("Timer").is_stopped():
		set_collision_mask_value(4, true)
		if is_on_floor():
			velocity.y += gravity * delta
	else: 
		set_collision_mask_value(4, false)
		
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState._give_score(1000)
		GameState.power = "water"
		GameState.big = true
		queue_free()
