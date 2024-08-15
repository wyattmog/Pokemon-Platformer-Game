extends Node2D
signal on_tile
var fort_node
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(get_node("Foreground Blocks/Question_Block2").get_children())
	#get_tree().call_group("enemies", "_on_player_grass_attack")
	GameState.game_ended = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("CanvasLayer/Label").text = "Coins: %d" % GameState.num_coins

func _on_charmander_enemy_death(name):
	get_node(name).set_collision_mask_value(1, false)

func _on_player_jumped():
	get_node("TileMap").set_layer_z_index(1, 2)

func _on_player_landed():
	get_node("TileMap").set_layer_z_index(1, 3)

#func _set_invincibility():
	#get_node("cha")
func _on_void_area_body_entered(body):
	if body.name == "Player":
		await get_tree().create_timer(.5).timeout
		GameState.game_ended = true
		get_tree().change_scene_to_file("res://main.tscn")
		#if get_tree():
			#get_tree().reload_current_scene()
		get_node("Player/Player").queue_free()
		#get_tree().change_scene_to_file("res://main.tscn")
		GameState.big = false
		GameState.power = ""
		
