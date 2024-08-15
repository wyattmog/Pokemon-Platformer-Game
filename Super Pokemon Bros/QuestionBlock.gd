extends StaticBody2D
@export var spawned_scene: PackedScene
signal mushroom_physics
var coin_scene = preload("res://spinning_coin.tscn")
var spawn = ""
var gravity: float = 2925
var initial_bounce_speed: float = -240
var orig_y_position
var orig_x_position
var coin_speed: float = 0
var block_speed: float = 0
var powerup_speed: float = 0
var played = false
var nearby = false
var bounce_type = ""
var spawnable
var coin_timer
var hit = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("question_block")
	orig_y_position = get_node("AnimatedSprite2D").position.y
	get_node("AnimatedSprite2D").play("turn")
	#var instance = spawned_scene.instantiate()
	#add_child(instance)
	#instance.connect("coin_spawned", spawn_coin)
#func spawn_coin():
	#spawn = "coin"
	#print("wpw")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.game_ended:
		print("wowwwwwww")
		if spawnable:
			spawnable.queue_free()
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
	if hit and spawn == "coin":
		if not get_node("CoinTimer").is_stopped():
			spawnable.position.y += coin_speed * delta
			coin_speed += gravity * delta
		else:
			if is_instance_valid(spawnable):
				coin_speed = 0
				await spawnable.get_node("AnimatedSprite2D").animation_finished
				spawnable.queue_free()
				hit=false
	elif hit and spawn == "powerup" and get_node("BounceTimer").is_stopped():
		if not get_node("PowerupTimer").is_stopped():
			spawnable.position.y += -.275
			#coin_speed += gravity * delta
		elif get_node("PowerupTimer").is_stopped():
			if is_instance_valid(spawnable):
				#coin_speed = 0 
				await spawnable.get_node("AnimatedSprite2D").animation_finished
				#spawnable.queue_free()
				hit=false
			
func _bounce():
	if spawned_scene.can_instantiate() and !played and spawned_scene.resource_path == "res://spinning_coin.tscn":
		spawn = "coin"
		#print(spawned_scene.resource_path)
		get_node("CoinTimer").start()
		spawnable = spawned_scene.instantiate() 
		spawnable.position = position + Vector2(0, -16)
		get_tree().root.add_child(spawnable)
	elif spawned_scene.can_instantiate() and !played and (spawned_scene.resource_path == "res://mushroom_power.tscn" or spawned_scene.resource_path == "res://grass_power.tscn" or spawned_scene.resource_path == "res://fire_power.tscn" or spawned_scene.resource_path == "res://water_power.tscn"):
		#print("wow")
		spawn = "powerup"
		get_node("PowerupTimer").start()
		spawnable = spawned_scene.instantiate()
		#spawnable.set_visible(0)
		spawnable.position = position + Vector2(0, -1)
		get_tree().root.add_child(spawnable)
	#elif spawned_scene.can_instantiate() and !played and spawned_scene.resource_path == "res://grass_power.tscn":
		##print("wow")
		#spawn = "powerup"
		#get_node("PowerupTimer").start()
		#spawnable = spawned_scene.instantiate()
		##spawnable.set_visible(0)
		#spawnable.position = position + Vector2(0, -1)
		#get_tree().root.add_child(spawnable)
	#elif spawned_scene.can_instantiate() and !played and spawned_scene.resource_path == "res://water_power.tscn":
		##print("wow")
		#spawn = "powerup"
		#get_node("PowerupTimer").start()
		#spawnable = spawned_scene.instantiate()
		##spawnable.set_visible(0)
		#spawnable.position = position + Vector2(0, -1)
		#get_tree().root.add_child(spawnable)
	block_speed = initial_bounce_speed
	coin_speed = initial_bounce_speed*1.5
	#powerup_speed = initial_bounce_speed
	get_node("BounceTimer").start()

func _grass_attack():
	if nearby and !played:
		hit = true
		_bounce()
		

func _on_area_2d_area_entered(body):
	if body.name == "PlayerArea":
		#print(body)
		hit = true
		_bounce()

func _on_area_2d_2_area_entered(area):
	if area.name == "GrassAttack":
		nearby = true


func _on_area_2d_2_area_exited(area):
	if area.name == "GrassAttack":
		nearby = false

