extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("BubbleSprite").play("dust")
	get_node("BubbleTimer").start()
func _process(delta):
	if get_node("BubbleTimer").is_stopped():
		queue_free()
	position.y -= 1
	position.x += randf_range(-1,1)

