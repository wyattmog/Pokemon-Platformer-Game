extends Node2D
func _ready():
	add_to_group("status_bar")
	get_node("Label").set_text(str("0000"))
func display_score():
	get_node("Label").set_text(str(GameState.score))
	
