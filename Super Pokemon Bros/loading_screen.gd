extends Control

func _ready():
	ResourceLoader.load_threaded_request(GameState.next_scene)
	
func _process(delta):
	print("proccessing")
	var progress = []
	ResourceLoader.load_threaded_get_status(GameState.next_scene, progress)
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(GameState.next_scene)
		get_tree().call_group("worlds", "_pipe_fade_in")
		get_tree().change_scene_to_packed(packed_scene)
		
