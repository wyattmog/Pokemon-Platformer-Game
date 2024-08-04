extends Node2D
signal on_tile

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_charmander_enemy_death(name):
	get_node(name).set_collision_mask_value(1, false)


func _on_player_jumped():
	get_node("TileMap").set_layer_z_index(1, 2)

	

func _on_player_landed():
	get_node("TileMap").set_layer_z_index(1, 3)




func _on_void_area_body_entered(body):
	if body.name == "Player":
		await get_tree().create_timer(.5).timeout
		get_node("Player/Player").queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
		
