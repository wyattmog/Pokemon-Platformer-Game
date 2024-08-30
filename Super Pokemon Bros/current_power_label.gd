extends Node2D
func _ready():
	add_to_group("status_bar")
func display_power():
	if GameState.power == "fire":
		get_node("AnimatedSprite2D").play("fire")
	elif GameState.power == "water":
		get_node("AnimatedSprite2D").play("water")
	elif GameState.power == "grass":
		get_node("AnimatedSprite2D").play("fire")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("big")
	else:
		get_node("AnimatedSprite2D").play("small")
