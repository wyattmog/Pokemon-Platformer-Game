extends Node2D
signal on_tile
var fort_node
var course_clear_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/smw_course_clear.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.checkpoint:
		#GameState.player.position = Vector2(2437, 505)
		GameState.player.position = Vector2(942, 401)
	else:
		GameState.player.position = Vector2(67, 491)
	add_to_group("worlds")
	get_node("BackroundMusic").play()
	GameState.game_ended = false
	
func _pipe():
	GameState.water_gravity = true
	ProjectSettings.set_setting("physics/2d/default_gravity", 150)

	get_node("Player/PipeAnimation").play("pipe_load")
	GameState.player._start_pipe_helper()
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://world_2_underwater.tscn")
func _on_enemy_death(name):
	get_node(name).set_collision_mask_value(1, false)

func _on_player_jumped():
	get_node("TileMap").set_layer_z_index(1, 2)

func _on_player_landed():
	get_node("TileMap").set_layer_z_index(1, 3)
func _on_player_death():
	get_tree().paused = true
func _on_player_dead():
	get_tree().paused = false
func _on_void_area_body_entered(body):
	if body.name == "Player":
		
		get_tree().call_group("player", "_death")
		await get_tree().create_timer(3).timeout
		GameState.big = false
		GameState.power = ""
		
func _on_finish_body_entered(body):
	if body.name == "Player":
		get_node("BackroundMusic").set_stream(course_clear_sound)
		get_node("BackroundMusic").play()



func _on_bounce_signal():
	pass # Replace with function body.


func _on_wartortle_3_enemy_death(body):
	pass # Replace with function body.
