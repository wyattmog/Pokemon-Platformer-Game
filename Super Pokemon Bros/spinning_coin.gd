extends Node2D
signal coin_spawned

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("coin_spawned")
	get_node("AnimatedSprite2D").play("spinning")
	GameState._give_coins(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
