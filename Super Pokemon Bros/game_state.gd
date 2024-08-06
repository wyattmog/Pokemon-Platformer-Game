extends Node

var num_coins: int = 0
# Called when the node enters the scene tree for the first time.
func _give_coins(num:int):
	num_coins += num
