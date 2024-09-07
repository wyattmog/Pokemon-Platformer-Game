extends Node2D
func _ready():
	add_to_group("status_bar")
	get_node("Label").set_text(str(GameState.time))
func display_time():
	get_node("Label").set_text(str(GameState.time))
	
