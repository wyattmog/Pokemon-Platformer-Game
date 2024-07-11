extends StaticBody2D

var gravity: float = 2925
var initial_bounce_speed: float = -240
var orig_y_position
var speed: float = 0
var played = false
# Called when the node enters the scene tree for the first time.
func _ready():
	orig_y_position = get_node("AnimatedSprite2D").position.y
	get_node("AnimatedSprite2D").play("turn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_node("AnimatedSprite2D").position.y == orig_y_position and played == true:
		get_node("AnimatedSprite2D").play("used")
	elif get_node("BounceTimer").is_stopped():
		get_node("AnimatedSprite2D").position.y = orig_y_position
		speed = 0.0
	else:
		get_node("AnimatedSprite2D").position.y += speed * delta
		speed += gravity * delta
		played = true
			
func _bounce():
	speed = initial_bounce_speed
	get_node("BounceTimer").start()


func _on_area_2d_area_entered(body):
	if body.name == "PlayerArea":
		_bounce()
