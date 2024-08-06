extends StaticBody2D
signal coin_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimatedSprite2D").play("coin")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#func _on_area_2d_area_entered(area):
	#get_node("AnimatedSprite2D").play("sparkle")
	#await get_node("AnimatedSprite2D").animation_finished
	#queue_free()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		get_node("AnimatedSprite2D").scale = Vector2(1.2, 1.2)
		get_node("AnimatedSprite2D").play("sparkle")
		GameState._give_coins(1)
	await get_node("AnimatedSprite2D").animation_finished
	get_node("AnimatedSprite2D").scale = Vector2(1, 1)
	queue_free()
