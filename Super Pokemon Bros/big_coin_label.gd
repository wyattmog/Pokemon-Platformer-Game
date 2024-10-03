extends Node2D
func _ready():
	add_to_group("status_bar")
	get_node("AnimatedSprite2D").play(str(GameState.big_num_coins))
func display_big_coins():
	get_node("AnimatedSprite2D").play(str(GameState.big_num_coins))
