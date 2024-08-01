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
