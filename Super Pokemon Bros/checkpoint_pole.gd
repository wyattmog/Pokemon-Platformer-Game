extends Node2D


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.big = true
		GameState.checkpoint = true
		queue_free()
