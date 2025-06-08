class_name InputManager extends Node

enum InputState {
	MENU = 0,
	ACTIVE = 1,
}

## Signals
# Player
signal mouse_look(delta: Vector2)
signal sprint_started()
signal sprint_stopped()
signal jump_requested()
signal movement_requested(direction: Vector2)
# Weapon
signal weapon_switch_requested(slot: int)
signal weapon_scroll_requested(direction: int)
signal fire_requested()
signal fire_released()
signal reload_requested()

signal menu_toggle_requested()

var current_state: InputState = InputState.ACTIVE
var mouse_sensitivity: float = 0.005

func _input(event: InputEvent) -> void:
	match current_state:
		InputState.MENU:
			_handle_menu_input(event)
		InputState.ACTIVE:
			_handle_active_input(event)

func _process(_delta: float) -> void:
	if current_state == InputState.ACTIVE:
		_handle_active_continuous_input()

func _handle_active_input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion:
		mouse_look.emit(-event.relative * mouse_sensitivity)
	
	# Fire input
	elif event.is_action_pressed("fire"):
		fire_requested.emit()
	elif event.is_action_released("fire"):
		fire_released.emit()
	
	elif event.is_action_pressed("reload"):
		reload_requested.emit()
	
	# Pause toggle
	elif event.is_action_pressed("ui_cancel"):
		menu_toggle_requested.emit()
	
   # Mouse wheel weapon switching
	elif event.is_action_pressed("scroll_next"):
		weapon_scroll_requested.emit(1)
	elif event.is_action_pressed("scroll_previous"):
		weapon_scroll_requested.emit(-1)
	

	
	# Weapon number keys (1-9)
	else:
		for i: int in range(1, 10):
			if event.is_action_pressed("num_" + str(i)):
				weapon_switch_requested.emit(i - 1)
				break
	
func _handle_active_continuous_input() -> void:
	# Handle player movement
	var move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	movement_requested.emit(move_dir)
	
	# Handle sprint
	if Input.is_action_just_pressed("sprint"):
		sprint_started.emit()
	elif Input.is_action_just_released("sprint"):
		sprint_stopped.emit()
		
	# Handle jump
	if Input.is_action_just_pressed("jump"):
		jump_requested.emit()
	
func _handle_menu_input(event: InputEvent) -> void:
	# Only handle pause toggle to return to game
	if event.is_action_pressed("ui_cancel"):
		menu_toggle_requested.emit()

# State management
func set_state(new_state: InputState) -> void:
	current_state = new_state
	_update_mouse_mode()

func _update_mouse_mode() -> void:
	match current_state:
		InputState.MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		InputState.ACTIVE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func enter_game() -> void:
	set_state(InputState.ACTIVE)

func enter_menu() -> void:
	set_state(InputState.MENU)

func is_in_game() -> bool:
	return current_state == InputState.ACTIVE
