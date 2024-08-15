extends Node
var game_ended = false
var big = false
var num_coins: int = 0
var power: String = ""
var direction: float = 0
var split = false
# Called when the node enters the scene tree for the first time.
func _give_coins(num:int):
	num_coins += num

