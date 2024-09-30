extends Node2D

@onready var music_player = get_node("Music")
@onready var select_player = get_node("SelectSound")

func _ready():
	get_node("LoadingScreenTransition/ColorRect2").set_visible(true)
	get_node("LoadingScreenTransition/FadePlayer1").play("fade_in")
	await get_tree().create_timer(0.1).timeout
	get_node("LoadingScreenTransition/ColorRect2").set_visible(false)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if GameState.next_scene == "":
			select_player.play()
		GameState.next_scene = "res://world_select.tscn"
		get_node("LoadingScreenTransition/FadePlayer1").play("fade_out")

func _on_loading_screen_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene_to_packed(GameState.loading_screen)
	else:

		get_node("GameTransition/FadePlayer").play("fade")
