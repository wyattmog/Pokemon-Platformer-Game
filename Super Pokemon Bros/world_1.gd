extends Node2D
signal on_tile
var fort_node
# Called when the node enters the scene tree for the first time.
func _ready():
	#if GameState.checkpoint:
		#GameState.player.position = Vector2(2437, 505)
	#else:
		#GameState.player.position = Vector2(63, 528)
	add_to_group("worlds")
	get_node("BackroundMusic").play()
	GameState.game_ended = false
	#print(get_node("Foreground Blocks/Question_Block2").get_children())
	#get_tree().call_group("enemies", "_on_player_grass_attack")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
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
#func _set_invincibility():
	#get_node("cha")
func _on_void_area_body_entered(body):
	if body.name == "Player":
		await get_tree().create_timer(.5).timeout
		#GameState.game_ended = true
		get_tree().change_scene_to_file("res://main.tscn")
		#if get_tree():
			#get_tree().reload_current_scene()
		get_node("Player/Player").queue_free()
		#get_tree().change_scene_to_file("res://main.tscn")
		GameState.big = false
		GameState.power = ""
		



#
#func _on_invincible_area_body_entered(body):
	#if body.name == "Player":
		#print("entered")
		#get_tree().call_group("enemies", "invincible_start")
		#get_tree().call_group("shell_projectile", "invincible_start")
		#get_tree().call_group("enemy_projectiles", "invincible_start")
#
#
#func _on_invincible_area_body_exited(body):
	#if body.name == "Player":
		#print("exited")
		#get_tree().call_group("enemies", "invincible_end")
		#get_tree().call_group("shell_projectile", "invincible_end")
		#get_tree().call_group("enemy_projectiles", "invincible_end")
