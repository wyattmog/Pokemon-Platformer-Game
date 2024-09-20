extends Node2D


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.big = true
		if get_tree().get_parent().name == "World1":
			GameState.checkpoint_level_1 = true
		elif get_tree().get_parent().name == "World2Underwater":
			GameState.checkpoint_level_2 = true
		get_node("AnimatedSprite2D").set_visible(0)
		get_node("AudioStreamPlayer").play()
		await get_tree().create_timer(1).timeout
		queue_free()
