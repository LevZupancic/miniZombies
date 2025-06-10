extends Node

const TAG: String = "[GameManager]"

# Current level reference
var current_level: BaseLevel

# UI container references (found dynamically in each level)
var world_3d: Node3D
var world_2d: Node2D
var gui: Control
var debug: Control

# Sub-container references for organized content management
var environment_container: Node3D
var level_geometry_container: Node3D
var characters_container: Node3D

# Current scene references for swapping
var current_3d_scene: Node3D
var current_2d_scene: Node2D
var current_gui_scene: Control

func _ready():
	print(TAG, " GameManager singleton ready")

# Load an entire level scene (replaces everything)
func load_level(level_path: String):
	print(TAG, " Loading level: ", level_path)
	
	# Clean up current level
	if current_level:
		current_level.queue_free()
		await current_level.tree_exited
	
	# Load new level
	var level_scene = load(level_path)
	if not level_scene:
		push_error(TAG, " Failed to load level: " + level_path)
		return
		
	current_level = level_scene.instantiate()
	get_tree().current_scene.add_child(current_level)
	
	# Find and cache UI container references using unique names (much faster!)
	world_3d = current_level.get_node("%World3D")
	world_2d = current_level.get_node("%World2D")
	gui = current_level.get_node("%GUI")
	debug = current_level.get_node("%Debug")
	
	# Find and cache 3D sub-containers using unique names
	environment_container = current_level.get_node("%Environment")
	level_geometry_container = current_level.get_node("%LevelGeometry")
	characters_container = current_level.get_node("%Characters")
	
	# Clear current scene references since we loaded a new level
	current_3d_scene = null
	current_2d_scene = null
	current_gui_scene = null
	
	# Validation
	if not world_3d:
		push_warning(TAG, " No %World3D node found in level: " + level_path)
	if not world_2d:
		push_warning(TAG, " No %World2D node found in level: " + level_path)
	if not gui:
		push_warning(TAG, " No %GUI node found in level: " + level_path)
	if not environment_container:
		push_warning(TAG, " No %Environment container found in level")
	if not level_geometry_container:
		push_warning(TAG, " No %LevelGeometry container found in level")
	if not characters_container:
		push_warning(TAG, " No %Characters container found in level")

# Change only the 3D content within current level
func change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if not world_3d:
		push_error(TAG, " No World3D container available")
		return
		
	print(TAG, " Changing 3D scene to: ", new_scene)
	
	# Handle current 3D scene
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_3d_scene.visible = false # Keep in memory and running
		else:
			world_3d.remove_child(current_3d_scene) # Keep in memory, stop running
	
	# Load and add new 3D scene
	var scene = load(new_scene)
	if not scene:
		push_error(TAG, " Failed to load 3D scene: " + new_scene)
		return
		
	var new = scene.instantiate()
	world_3d.add_child(new)
	current_3d_scene = new

# Change only the 2D content within current level
func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if not world_2d:
		push_error(TAG, " No World2D container available")
		return
		
	print(TAG, " Changing 2D scene to: ", new_scene)
	
	# Handle current 2D scene
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_2d_scene.visible = false # Keep in memory and running
		else:
			world_2d.remove_child(current_2d_scene) # Keep in memory, stop running
	
	# Load and add new 2D scene
	var scene = load(new_scene)
	if not scene:
		push_error(TAG, " Failed to load 2D scene: " + new_scene)
		return
		
	var new = scene.instantiate()
	world_2d.add_child(new)
	current_2d_scene = new

# Change only the GUI content within current level
func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if not gui:
		push_error(TAG, " No GUI container available")
		return
		
	print(TAG, " Changing GUI scene to: ", new_scene)
	
	# Handle current GUI scene
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_gui_scene.visible = false # Keep in memory and running
		else:
			gui.remove_child(current_gui_scene) # Keep in memory, stop running
	
	# Load and add new GUI scene
	var scene = load(new_scene)
	if not scene:
		push_error(TAG, " Failed to load GUI scene: " + new_scene)
		return
		
	var new = scene.instantiate()
	gui.add_child(new)
	current_gui_scene = new
	current_gui_scene.visible = true

# Specialized functions for swapping organized 3D content

# Change environment (lighting, sky, atmosphere)
func change_environment(new_environment: String, delete: bool = true) -> void:
	if not environment_container:
		push_error(TAG, " No Environment container available")
		return
		
	print(TAG, " Changing environment to: ", new_environment)
	
	# Clear current environment
	if delete:
		for child: Node3D in environment_container.get_children():
			child.queue_free()
	
	# Load and add new environment
	var scene = load(new_environment)
	if not scene:
		push_error(TAG, " Failed to load environment: " + new_environment)
		return
		
	var new_env = scene.instantiate()
	environment_container.add_child(new_env)

# Change level geometry (walls, floors, buildings)
func change_level_geometry(new_geometry: String, delete: bool = true) -> void:
	if not level_geometry_container:
		push_error(TAG, " No LevelGeometry container available")
		return
		
	print(TAG, " Changing level geometry to: ", new_geometry)
	
	# Clear current geometry
	if delete:
		for child: Node3D in level_geometry_container.get_children():
			child.queue_free()
	
	# Load and add new geometry
	var scene = load(new_geometry)
	if not scene:
		push_error(TAG, " Failed to load level geometry: " + new_geometry)
		return
		
	var new_geo = scene.instantiate()
	level_geometry_container.add_child(new_geo)

# Change characters (enemies, NPCs)
func change_characters(new_characters: String, delete: bool = true) -> void:
	if not characters_container:
		push_error(TAG, " No Characters container available")
		return
		
	print(TAG, " Changing characters to: ", new_characters)
	
	# Clear current characters
	if delete:
		for child: Node3D in characters_container.get_children():
			child.queue_free()
	
	# Load and add new characters
	var scene = load(new_characters)
	if not scene:
		push_error(TAG, " Failed to load characters: " + new_characters)
		return
		
	var new_chars = scene.instantiate()
	characters_container.add_child(new_chars)

# Add individual items to specific containers
func add_to_environment(scene_path: String) -> Node3D:
	if not environment_container:
		push_error(TAG, " No Environment container available")
		return null
		
	var scene = load(scene_path)
	if not scene:
		push_error(TAG, " Failed to load scene: " + scene_path)
		return null
		
	var instance = scene.instantiate()
	environment_container.add_child(instance)
	return instance

func add_to_level_geometry(scene_path: String) -> Node3D:
	if not level_geometry_container:
		push_error(TAG, " No LevelGeometry container available")
		return null
		
	var scene = load(scene_path)
	if not scene:
		push_error(TAG, " Failed to load scene: " + scene_path)
		return null
		
	var instance = scene.instantiate()
	level_geometry_container.add_child(instance)
	return instance

func add_to_characters(scene_path: String) -> Node3D:
	if not characters_container:
		push_error(TAG, " No Characters container available")
		return null
		
	var scene = load(scene_path)
	if not scene:
		push_error(TAG, " Failed to load scene: " + scene_path)
		return null
		
	var instance = scene.instantiate()
	characters_container.add_child(instance)
	return instance

# Utility functions
func get_current_level() -> BaseLevel:
	return current_level

func is_level_loaded() -> bool:
	return current_level != null

# Get container references for direct access
func get_environment_container() -> Node3D:
	return environment_container

func get_level_geometry_container() -> Node3D:
	return level_geometry_container

func get_characters_container() -> Node3D:
	return characters_container
