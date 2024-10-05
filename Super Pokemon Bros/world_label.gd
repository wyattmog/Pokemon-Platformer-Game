extends Node2D
func _ready():
	add_to_group("status_bar")
	if GameState.curr_world == 0:
		get_node("Label").set_text("Ash's House")
	else:
		get_node("Label").set_text("Ash's Island "+str(GameState.curr_world))
func display_world():
	if GameState.curr_world == 0:
		get_node("Label").set_text("Ash's House")
	else:
		get_node("Label").set_text("Ash's Island "+str(GameState.curr_world))
	
	
	
