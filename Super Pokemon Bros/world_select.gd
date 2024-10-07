extends Node2D
var curr_world
@onready var music_player = get_node("Music")
@onready var select_player = get_node("SelectSound")
const start = Vector2(-48,230)
const world_1 = Vector2(256,306)
const world_2 = Vector2(461,-60)
const world_3 = Vector2(257,-229)
func _ready():
	get_node("LoadingScreenTransition/ColorRect2").set_visible(true)
	get_node("LoadingScreenTransition/FadePlayer1").play("fade_in")
	GameState.game_ended = true
	GameState.time = 150
	music_player.play()
	GameState.water_gravity = false
	ProjectSettings.set_setting("physics/2d/default_gravity", 530)
	if GameState.world_unlock == 1:
		get_node("WorldScreen").play("World1")
	elif GameState.world_unlock == 2:
		get_node("WorldScreen").play("World2")
	elif GameState.world_unlock == 3:
		get_node("WorldScreen").play("World3")
	if GameState.curr_world == 0:
		get_node("AnimatedSprite2D").position = start
	elif GameState.curr_world == 1:
		get_node("AnimatedSprite2D").position = world_1
	elif GameState.curr_world == 2:
		get_node("AnimatedSprite2D").position = world_2
	elif GameState.curr_world == 3:
		get_node("AnimatedSprite2D").position = world_3
	if GameState.power != "":
		get_node("AnimatedSprite2D").play(GameState.power+"Idle")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("BigIdle")
	else:
		get_node("AnimatedSprite2D").play("SmallIdle")
	await get_tree().create_timer(0.1).timeout
	get_node("LoadingScreenTransition/ColorRect2").set_visible(false)
func _input(event):
	curr_world = get_node("AnimatedSprite2D").position
	if event.is_action_pressed("ui_accept"):
		if curr_world == world_1:
			GameState.curr_world = 1
			GameState.next_scene = "res://world_1.tscn"
			get_node("LoadingScreenTransition/FadePlayer1").play("fade_out")
		elif curr_world == world_2:
			if GameState.checkpoint_level_2:
				GameState.curr_world = 2
				GameState.water_gravity = true
				ProjectSettings.set_setting("physics/2d/default_gravity", 150)
				GameState.next_scene = "res://world_2_underwater.tscn"
				get_node("LoadingScreenTransition/FadePlayer1").play("fade_out")
			else:
				GameState.curr_world = 2
				GameState.next_scene = "res://world_2.tscn"
				get_node("LoadingScreenTransition/FadePlayer1").play("fade_out")
		elif curr_world == world_3:
			GameState.curr_world = 3
			GameState.next_scene = "res://world_3.tscn"
			get_node("LoadingScreenTransition/FadePlayer1").play("fade_out")
	if event.is_action_pressed("ui_up"):
		if curr_world == world_1 and GameState.world_unlock > 1:
			get_node("AnimationPlayer").play("world1-world2")
		elif curr_world == world_2 and GameState.world_unlock > 2:
			get_node("AnimationPlayer").play("world2-world3")
	elif event.is_action_pressed("ui_right"):
		if curr_world == start:
			get_node("AnimationPlayer").play("start-world1")
	elif event.is_action_pressed("ui_left"):
		if curr_world == world_1:
			get_node("AnimationPlayer").play("world1-start")
	elif event.is_action_pressed("ui_down"):
		if curr_world == world_2:
			get_node("AnimationPlayer").play("world2-world1")
		elif curr_world == world_3:
			get_node("AnimationPlayer").play("world3-world2")
func _walkRight():
	get_node("AnimatedSprite2D").flip_h = false
	if GameState.power != "":
		if GameState.power == "fire":
			get_node("AnimatedSprite2D").play("FireWalk")
		elif GameState.power == "water":
			get_node("AnimatedSprite2D").play("WaterWalk")
		elif GameState.power == "grass":
			get_node("AnimatedSprite2D").play("GrassWalk")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("BigWalk")
	else:
		get_node("AnimatedSprite2D").play("SmallWalk")

func _walkLeft():
	get_node("AnimatedSprite2D").flip_h = true
	if GameState.power != "":
		if GameState.power == "fire":
			get_node("AnimatedSprite2D").play("FireWalk")
		elif GameState.power == "water":
			get_node("AnimatedSprite2D").play("WaterWalk")
		elif GameState.power == "grass":
			get_node("AnimatedSprite2D").play("GrassWalk")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("BigWalk")
	else:
		get_node("AnimatedSprite2D").play("SmallWalk")
	
func _back():
	if GameState.power != "":
		if GameState.power == "fire":
			get_node("AnimatedSprite2D").play("FireBackWalk")
		elif GameState.power == "water":
			get_node("AnimatedSprite2D").play("WaterBackWalk")
		elif GameState.power == "grass":
			get_node("AnimatedSprite2D").play("GrassBackWalk")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("BigBackWalk")
	else:
		get_node("AnimatedSprite2D").play("SmallBackWalk")

func _front():
	if GameState.power != "":
		if GameState.power == "fire":
			get_node("AnimatedSprite2D").play("FireFrontWalk")
		elif GameState.power == "water":
			get_node("AnimatedSprite2D").play("WaterFrontWalk")
		elif GameState.power == "grass":
			get_node("AnimatedSprite2D").play("GrassFrontWalk")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("BigFrontWalk")
	else:
		get_node("AnimatedSprite2D").play("SmallFrontWalk")
func _idle():
	curr_world = get_node("AnimatedSprite2D").position
	if curr_world == start:
		GameState.curr_world = 0
	elif curr_world == world_1:
		GameState.curr_world = 1
	elif curr_world == world_2:
		GameState.curr_world = 2
	elif curr_world == world_3:
		GameState.curr_world = 3
	get_tree().call_group("status_bar", "display_world")
	select_player.play()
	curr_world = get_node("AnimatedSprite2D").position
	if GameState.power != "":
		if GameState.power == "fire":
			get_node("AnimatedSprite2D").play("FireIdle")
		elif GameState.power == "water":
			get_node("AnimatedSprite2D").play("WaterIdle")
		elif GameState.power == "grass":
			get_node("AnimatedSprite2D").play("GrassIdle")
	elif GameState.big:
		get_node("AnimatedSprite2D").play("BigIdle")
	else:
		get_node("AnimatedSprite2D").play("SmallIdle")


func _on_loading_screen_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene_to_packed(GameState.loading_screen)
