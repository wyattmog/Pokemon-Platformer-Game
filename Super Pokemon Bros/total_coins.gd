extends Node2D
func _ready():
	get_node("Label").set_text(str(GameState.big_num_coins))
