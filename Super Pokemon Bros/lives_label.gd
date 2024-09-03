extends Node2D
func _ready():
	add_to_group("status_bar")
	get_node("Label").set_text(str(GameState.num_lives))
func display_lives():
	
	
	get_node("Label").set_text(str(GameState.num_lives))
	
	
	
