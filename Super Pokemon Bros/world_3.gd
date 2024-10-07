extends Node2D
signal on_tile
var fort_node
var course_clear_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/smw_course_clear.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().call_group("status_bar", "_timer_loop")
	get_node("LoadingScreenTransition/ColorRect2").set_visible(true)
	get_node("LoadingScreenTransition/FadePlayer1").play("fade_in")
	if GameState.checkpoint_level_1:
		GameState.player.position = Vector2(2449, 292)
	else:
		GameState.player.position = Vector2(82, 488)
	add_to_group("worlds")
	get_node("BackroundMusic").play()
	GameState.game_ended = false
	await get_tree().create_timer(0.1).timeout
	get_node("LoadingScreenTransition/ColorRect2").set_visible(false)
	

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


func _on_loading_screen_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene_to_packed(GameState.loading_screen)
