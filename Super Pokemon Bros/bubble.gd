extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("BubbleSprite").play("dust")
	get_node("BubbleTimer").start()
	_move()
func _move():
	while !get_node("BubbleTimer").is_stopped() and ResourceLoader.exists(str(get_tree())):
		position.y -= 1
		position.x += randf_range(-1,1)
		await get_tree().create_timer(0.0).timeout
	queue_free()
