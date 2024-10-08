extends StaticBody2D
signal coin_collected
@onready var audio_player = get_node("SoundEffects")
var coin_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/coin.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.collected_items.has(position):
		queue_free()
	get_node("AnimatedSprite2D").play("coin")




func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.collected_items[position] = true
		get_node("AnimatedSprite2D").scale = Vector2(1.2, 1.2)
		get_node("AnimatedSprite2D").play("sparkle")
		GameState._give_score(200)
		audio_player.set_stream(coin_sound)
		audio_player.play()
		GameState._give_coins(1)
	await get_node("AnimatedSprite2D").animation_finished
	get_node("AnimatedSprite2D").scale = Vector2(1, 1)
	queue_free()
