extends Node2D
func _ready():
	add_to_group("point_screen")
	GameState.total_points = GameState.time * 50
	get_node("Label").set_text(str(GameState.total_points))
func _subtract():
	if GameState.total_points >= 100:
		GameState.total_points -= 100
	elif GameState.total_points >= 50:
		GameState.total_points -= 50
	elif GameState.total_points >= 10:
		GameState.total_points -= 10
	get_node("Label").set_text(str(GameState.total_points))
