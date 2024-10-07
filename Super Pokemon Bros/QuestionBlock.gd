extends StaticBody2D
@export var spawned_scene: PackedScene
signal mushroom_physics
var coin_scene = preload("res://spinning_coin.tscn")
@onready var audio_player = get_node("SoundEffects")
var powerup_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/sprout-item.wav")
var hit_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/slam.wav")
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
func _ready():
	add_to_group("question_block")
	orig_y_position = get_node("AnimatedSprite2D").position.y
	get_node("AnimatedSprite2D").play("turn")
func _process(delta):
	if GameState.game_ended:
		if spawnable and is_instance_valid(spawnable):
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
	if hit and spawn == "coin":
		if not get_node("CoinTimer").is_stopped():
			spawnable.position.y += coin_speed * delta
			coin_speed += gravity * delta
		else:
			if is_instance_valid(spawnable):
				coin_speed = 0
				await spawnable.get_node("AnimatedSprite2D").animation_finished
				hit=false
				spawnable.queue_free()
	elif hit and spawn == "powerup" and get_node("BounceTimer").is_stopped():
		if not get_node("PowerupTimer").is_stopped() and is_instance_valid(spawnable):
			spawnable.position.y += -.275
		elif get_node("PowerupTimer").is_stopped():
			if is_instance_valid(spawnable):
				await spawnable.get_node("AnimatedSprite2D").animation_finished
				hit=false
			
func _bounce():
	if GameState.player.velocity.y <= 0:
		if spawned_scene.can_instantiate() and !played and spawned_scene.resource_path == "res://spinning_coin.tscn":
			spawn = "coin"
			get_node("CoinTimer").start()
			spawnable = spawned_scene.instantiate() 
			spawnable.position = position + Vector2(0, -16)
			get_tree().root.call_deferred("add_child", spawnable)
		elif spawned_scene.can_instantiate() and !played and (spawned_scene.resource_path == "res://mushroom_power.tscn" or spawned_scene.resource_path == "res://grass_power.tscn" or spawned_scene.resource_path == "res://fire_power.tscn" or spawned_scene.resource_path == "res://water_power.tscn"):
			audio_player.set_stream(powerup_sound)
			audio_player.set_volume_db(0)
			audio_player.play()
			spawn = "powerup"
			get_node("PowerupTimer").start()
			spawnable = spawned_scene.instantiate()
			spawnable.position = position + Vector2(0, -1)
			get_tree().root.call_deferred("add_child", spawnable)
		block_speed = initial_bounce_speed
		coin_speed = initial_bounce_speed*1.5
		get_node("BounceTimer").start()

func _grass_attack():
	if nearby and !played:
		hit = true
		_bounce()
		

func _on_area_2d_area_entered(body):
	if body.name == "PlayerArea" and !audio_player.is_playing():
		audio_player.set_stream(hit_sound)
		audio_player.set_volume_db(-10)

		audio_player.play()
		hit = true
		_bounce()

func _on_area_2d_2_area_entered(area):
	if area.name == "GrassAttack":
		nearby = true


func _on_area_2d_2_area_exited(area):
	if area.name == "GrassAttack":
		nearby = false

