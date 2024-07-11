extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("ui_right"):
	pass
		
	
		


func _on_button_focus_entered():
	get_node("AnimatedSprite2D").play("default")
	get_node("AnimatedSprite2D").position = Vector2(301, 224)


func _on_button_2_focus_entered():
	get_node("AnimatedSprite2D").position =Vector2(438, 224)
	
	


func _on_button_pressed():
	get_tree().change_scene_to_file("res://world_1.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://world_2.tscn")
