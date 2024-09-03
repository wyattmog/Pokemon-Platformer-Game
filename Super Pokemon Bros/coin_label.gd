extends Node2D
func _ready():
	add_to_group("status_bar")
	get_node("Label").set_text("00")
func display_coins():
	get_node("Label").set_text(str(GameState.num_coins))
	
	
