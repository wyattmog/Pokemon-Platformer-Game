extends Node2D

func _ready():
	if GameState.collected_items.has(position):
		queue_free()
func _on_area_2d_body_entered(body):
	GameState.collected_items[position] = true
	if body.name == "Player":
		GameState.big = true
		print(get_tree().current_scene.name)
		if get_tree().current_scene.name == "World1":
			GameState.checkpoint_level_1 = true
		elif get_tree().current_scene.name == "World2Underwater":
			GameState.checkpoint_level_2 = true
			print("wow")
		get_node("AnimatedSprite2D").set_visible(0)
		get_node("AudioStreamPlayer").play()
		await get_tree().create_timer(1).timeout
		queue_free()
