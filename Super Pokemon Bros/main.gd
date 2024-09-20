extends Control
var started = false
@onready var music_player = get_node("Music")
@onready var select_player = get_node("SelectSound")
func _ready():
	music_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GameState.game_ended = true
	
		


func _on_button_focus_entered():
	if started:
		select_player.play()
	get_node("AnimatedSprite2D").play("default")
	get_node("AnimatedSprite2D").position = Vector2(252, 251)


func _on_button_2_focus_entered():
	started = true
	select_player.play()
	get_node("AnimatedSprite2D").position =Vector2(442, 251)
	
	



func _on_button_pressed():
	get_tree().change_scene_to_file("res://world_1.tscn")
	


func _on_button_2_pressed():
	if GameState.checkpoint:
		get_tree().change_scene_to_file("res://world_2_underwater.tscn")
	else:
		get_tree().change_scene_to_file("res://world_2.tscn")


func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://world_3.tscn")


func _on_button_3_focus_entered():
	started = true
	select_player.play()
	get_node("AnimatedSprite2D").position =Vector2(252, 411)
