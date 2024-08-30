extends Node2D
func _ready():
	add_to_group("status_bar")
func display_lives():
	get_node("Label").set_text(GameState.num_lives)
	
