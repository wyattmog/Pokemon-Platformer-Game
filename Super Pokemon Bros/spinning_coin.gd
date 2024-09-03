extends Node2D
signal coin_spawned
@onready var audio_player = get_node("SoundEffects")
var coin_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/coin.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	audio_player.set_stream(coin_sound)
	audio_player.play()
	emit_signal("coin_spawned")
	get_node("AnimatedSprite2D").play("spinning")
	GameState._give_coins(1)
	GameState._give_score(200)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
