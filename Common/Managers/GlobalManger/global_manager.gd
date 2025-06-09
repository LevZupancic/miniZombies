class_name GlobalManager extends Node

var debug: Debug
var game_manager: GameManager

func _ready() -> void:
	print()
	game_manager = GameManager.new()
