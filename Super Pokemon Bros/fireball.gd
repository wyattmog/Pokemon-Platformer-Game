extends CharacterBody2D
var SPEED = 200.0
const JUMP_VELOCITY = -200.0
var direction
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("projectiles")
	velocity.x = SPEED * GameState.direct
	get_node("AnimatedSprite2D").play("fireball")
	
func _physics_process(delta):
	# Add the gravity
	if velocity.x > 0:
		direction = 1
	elif velocity.x < 0:
		direction = -1
	if !velocity.x and direction == 1:
		velocity.x = SPEED * -1
	elif !velocity.x and direction == -1:
		velocity.x = SPEED
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	else:
		velocity.y = JUMP_VELOCITY

	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
	


func _on_area_2d_body_entered(body):
	if body.name == "Charmander":
		#get_tree().call_group("enemies", "_on_player_grass_attack")
		queue_free()
		
		
		
		
