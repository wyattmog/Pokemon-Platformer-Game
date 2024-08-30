class_name Global 
extends Node
static var player = null
var game_ended = false
var big = false
var big_num_coins: int = 0
var num_coins: int = 0
var power: String = ""
var direct: float = 0
var split = false
var num_lives: int = 0
var projectile_adjustment = 0
var invincible = false
var checkpoint = false
# Called when the node enters the scene tree for the first time.
func _give_coins(num:int):
	num_coins += num
	get_tree().call_group("status_bar", "display_coins")
func _give_big_coins(num:int):
	big_num_coins += num
	get_tree().call_group("status_bar", "display_big_coins")
func _add_lives():
	get_tree().call_group("status_bar", "display_lives")
func _remove_lives():
	get_tree().call_group("status_bar", "display_lives")
func _give_score():
	get_tree().call_group("status_bar", "display_score")
func display_power():
	get_tree().call_group("status_bar", "display_power")

