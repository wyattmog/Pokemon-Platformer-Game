class_name Global 
extends Node
static var player = null
var cutscene = false
var game_ended = false
var big = false
var big_num_coins: int = 0
var num_coins: int = 0
var power: String = ""
var direct: float = 0
var split = false
var num_lives: int = 5
var projectile_adjustment = 0
var stomp_counter = 0
var invincible = false
var checkpoint = false
var score = 0
var water_gravity = false
var shellkicked = false
var time = 300
var total_points = 0
# Called when the node enters the scene tree for the first time.
func _process(delta):
	get_tree().call_group("status_bar", "display_time")
	if GameState.cutscene:
		get_tree().call_group("status_bar", "change_time")
func _give_coins(num:int):
	num_coins += num
	get_tree().call_group("status_bar", "display_coins")
func _give_big_coins(num:int):
	big_num_coins += num
	get_tree().call_group("status_bar", "display_big_coins")
func _add_lives(num:int):
	num_lives += 1
	get_tree().call_group("status_bar", "display_lives")
func _remove_lives(num:int):
	num_lives -= 1
	get_tree().call_group("status_bar", "display_lives")
func _give_score(num:int):
	score += num
	get_tree().call_group("status_bar", "display_score")
func display_power():
	get_tree().call_group("status_bar", "display_power")

