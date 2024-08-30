extends Node2D
func _ready():
	add_to_group("status_bar")
func display_coins():
	get_node("Label").set_text(str(GameState.num_coins))
	
	
