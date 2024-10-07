extends Node2D
var time = 0
var stop = false
func _ready():
	add_to_group("status_bar")
	time = GameState.time
	display_time()
func _timer_loop():
	time = GameState.time
	while time >= 0 and !GameState.player.disable_input:
		display_time()
		time -= 1
		GameState.time = time
		await get_tree().create_timer(1.0).timeout
	if !GameState.player.disable_input:
		get_tree().call_group("player", "_death")
func display_time():
	get_node("Label").set_text(str(time))
