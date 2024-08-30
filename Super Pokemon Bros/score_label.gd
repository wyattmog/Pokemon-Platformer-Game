extends Node2D
func _ready():
	add_to_group("status_bar")
func display_score():
	get_node("Label").set_text(GameState.big_num_coins)
	
