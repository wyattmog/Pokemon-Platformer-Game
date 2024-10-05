extends Node2D
var time = 0
var stop = false
func _ready():
	time = GameState.time
	add_to_group("status_bar")
func _timer_loop():
	while time >= 0 and !GameState.player.disable_input:
		display_time()
		get_node("Label").set_text(str(time))
		time -= 1
		await get_tree().create_timer(1.0).timeout
	if !GameState.player.disable_input:
		get_tree().call_group("player", "_death")
func display_time():
	get_node("Label").set_text(str(time))
	
