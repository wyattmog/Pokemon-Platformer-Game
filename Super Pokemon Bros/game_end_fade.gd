extends Node2D


func _on_area_2d_body_entered(body):
	get_node("AnimationPlayer").play("fade")
	GameState.player.set_z_index(5)
	GameState.cutscene = true
