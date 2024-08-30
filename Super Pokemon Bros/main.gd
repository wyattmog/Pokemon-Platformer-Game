extends Control
var started = false
@onready var music_player = get_node("Music")
@onready var select_player = get_node("SelectSound")
#var music_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/03. Yoshi's Island-[AudioTrimmer.com].wav")
#var select_sound = preload("res://sounds/SNES - Super Mario World - Sound Effects/map-spot.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	#music_player.set_stream(music_sound)
	music_player.play()
	#var player = AudioStreamPlayer.new()
	#var stream = AudioStreamPolyphonic.new()
	#var playback:AudioStreamPlaybackPolyphonic
	#stream.polyphony = 10
	#player.stream = stream
	#add_child(player)
	#player.play()
	#playback = player.get_stream_playback()
	#playback.play_stream(music_sound)
	#print(playback)
	
	#var player = AudioStreamPlayer.new()
	#var stream = AudioStreamPolyphonic.new()
	#var instance = audio_player.duplicate()
	#add_child(instance)
	#var polyphonic_stream = AudioStreamPolyphonic.new()
	#audio_player.set_stream(polyphonic_stream)
	#audio_player.play()
	#var playback = audio_player.get_stream_playback()
	#playback.play_stream(music_sound)
	
	#audio_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("ui_right"):
	GameState.game_ended = true
	
		


func _on_button_focus_entered():
	if started:
		#select_player.set_stream(select_sound)
		#select_player.play(select_sound)
		select_player.play()
	get_node("AnimatedSprite2D").play("default")
	get_node("AnimatedSprite2D").position = Vector2(301, 224)


func _on_button_2_focus_entered():
	started = true
	#select_player.set_stream(select_sound)
	select_player.play()
	
	get_node("AnimatedSprite2D").position =Vector2(438, 224)
	
	



func _on_button_pressed():
	get_tree().change_scene_to_file("res://world_1.tscn")
	


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://world_2.tscn")
