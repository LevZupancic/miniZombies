class_name GameManager extends Node

@export var world_3d: Node3D
@export var world_2d: Node2D
@export var gui: Control
@export var debug: Control

var current_3d_scene: Node3D
var current_2d_scene: Node2D
var current_gui_scene: Control

func _ready() -> void:
	print("here")
	change_gui_scene("res://Common/Components/GUI/GuiComponent.tscn")


func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	print("change gui scene")
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_gui_scene.visible = false # Keep in memory and running
		else:
			gui.remove_child(current_gui_scene) # Keep in memory stop running
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	current_gui_scene.visible = true

func change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_3d_scene.visible = false # Keep in memory and running
		else:
			gui.remove_child(current_3d_scene) # Keep in memory stop running
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_3d_scene = new

func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_2d_scene.visible = false # Keep in memory and running
		else:
			gui.remove_child(current_3d_scene) # Keep in memory stop running
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_2d_scene = new
