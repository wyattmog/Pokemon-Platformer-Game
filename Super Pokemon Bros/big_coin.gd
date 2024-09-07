extends StaticBody2D
signal coin_collected
@onready var audio_player = get_node("SoundEffects")
var coin_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/coin-special.wav")
var stop = false
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimatedSprite2D").play("big_coin")

func _on_area_2d_body_entered(body):
	if body.name == "Player" and !stop:
		stop = true
		get_node("AnimatedSprite2D").scale = Vector2(1.2, 1.2)
		GameState._give_score(1000)
		get_node("AnimatedSprite2D").play("sparkle")
		audio_player.set_stream(coin_sound)
		audio_player.play()
		GameState._give_big_coins(1)
	await get_node("AnimatedSprite2D").animation_finished
	get_node("AnimatedSprite2D").scale = Vector2(2, 2)
	queue_free()
