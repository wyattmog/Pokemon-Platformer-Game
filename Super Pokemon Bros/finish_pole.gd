extends Node2D

func _ready():
	get_node("AnimationPlayer").play("move")

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameState.game_ended = true
		queue_free()
