extends StaticBody2D
@export var spawned_scene: PackedScene

var gravity: float = 2925
var initial_bounce_speed: float = -240
var orig_y_position
var orig_x_position
var coin_speed: float = 0
var block_speed: float = 0
var played = false
var nearby = false
var bounce_type = ""
var coin
var coin_timer
var hit = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("question_block")
	orig_y_position = get_node("AnimatedSprite2D").position.y
	get_node("AnimatedSprite2D").play("turn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_node("AnimatedSprite2D").position.y == orig_y_position and played == true:
		get_node("AnimatedSprite2D").play("used")
	elif get_node("BounceTimer").is_stopped():
		get_node("AnimatedSprite2D").position.y = orig_y_position
		block_speed = 0.0
	else: 
		get_node("AnimatedSprite2D").play("used")
		get_node("AnimatedSprite2D").position.y += block_speed * delta 
		block_speed += gravity * delta
		played = true
		#else:
			#get_node("AnimatedSprite2D").play("used_animation")
			#await get_node("AnimatedSprite2D").animation_finished
			#played = true
	if hit:
		if not get_node("CoinTimer").is_stopped():
			coin.position.y += coin_speed * delta
			coin_speed += gravity * delta
		else:
			if is_instance_valid(coin):
				coin_speed = 0
				await coin.get_node("AnimatedSprite2D").animation_finished
				coin.queue_free()
				hit=false
			
func _bounce():
	if spawned_scene.can_instantiate() and !played:
		get_node("CoinTimer").start()
		coin = spawned_scene.instantiate() 
		coin.position = position + Vector2(0, -16)
		get_tree().root.add_child(coin)
	block_speed = initial_bounce_speed
	coin_speed = initial_bounce_speed*1.5
	get_node("BounceTimer").start()

func _grass_attack():
	if nearby and !played:
		hit = true
		_bounce()
		

func _on_area_2d_area_entered(body):
	if body.name == "PlayerArea":
		hit = true
		_bounce()

func _on_area_2d_2_area_entered(area):
	if area.name == "GrassAttack":
		nearby = true


func _on_area_2d_2_area_exited(area):
	if area.name == "GrassAttack":
		nearby = false

