class_name Player extends CharacterBody3D


const SPEED: float = 5.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation: AnimationPlayer = $ScreenEffectController/DamageTexture/DamageAnimation
@onready var hit_animation: AnimationPlayer = $ScreenEffectController/HitTexture/HitAnimation
@onready var game_over_menu: GameOverMenu = $GameOverMenu
@onready var inventory_manager: InventoryManager = $SubViewportContainer/SubViewport/WeaponCamera/InventoryManager

@export var jump_height: float = 1.0
@export var max_hitpoints: int = 100

var speed_multi: float = 1.0
var mouse_motion: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var wants_jump: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var hitpoints: int = max_hitpoints

func _ready() -> void:
	# Connect to InputManager signals
	Input_Manager.mouse_look.connect(_on_mouse_look)
	Input_Manager.menu_toggle_requested.connect(_on_pause_toggle)
	Input_Manager.movement_requested.connect(_on_movement_requested)
	Input_Manager.jump_requested.connect(_on_jump_requested)
	Input_Manager.sprint_started.connect(_on_sprint_started)
	Input_Manager.sprint_stopped.connect(_on_sprint_stopped)
	# Set initial state
	Input_Manager.enter_game()
	
	# Locks the mouse to screen, so you don't go off screen, and will always listen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var gun_scene = preload("res://Entities/Weapons/Guns/HitscanGuns/Rifles/M4A1/M4A1_scene.tscn")
	inventory_manager.instantiate_weapon(gun_scene)
	var gun_scene2 = preload("res://Entities/Weapons/Guns/HitscanGuns/Snipers/HuntingRifle/hunting_rifle_scene.tscn")
	inventory_manager.instantiate_weapon(gun_scene2)

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	# Add the gravity
	if not is_on_floor():
		var fall_multiplier: float = 2.0 if velocity.y < 0 else 1.0
		velocity += get_gravity() * delta * fall_multiplier

	# Handle jump
	if wants_jump and is_on_floor():
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		wants_jump = false
		
	var speed: float = SPEED * speed_multi
	var direction: Vector3 = (transform.basis * Vector3(movement_direction.x, 0, movement_direction.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x) # rotate camera left/right
	camera_pivot.rotate_x(mouse_motion.y) # rotate camera up/down
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	mouse_motion = Vector2.ZERO

func take_damage(damage: int) -> void:
	hit_animation.play("Hit")
	hitpoints -= damage
	damage_animation.stop(false)
	match hitpoints:
		_ when hitpoints > max_hitpoints * 0.5:
			damage_animation.play("LowDamage")
		_ when hitpoints > max_hitpoints * 0.25:
			damage_animation.play("MediumDamage")
		_ when hitpoints > 0:
			damage_animation.play("HighDamage")
		_ when hitpoints <= 0:
			damage_animation.play("RESET")
			handle_death()


func handle_death() -> void:
	print("died")
	Input_Manager.enter_menu()
	game_over_menu.game_over()

## Signal functions
func _on_mouse_look(direction: Vector2) -> void:
	mouse_motion = direction
	
func _on_jump_requested() -> void:
	if is_on_floor():
		wants_jump = true

func _on_sprint_started() -> void:
	if is_on_floor():
		speed_multi = 2.0
		
func _on_sprint_stopped() -> void:
	speed_multi = 1.0

func _on_movement_requested(direction: Vector2) -> void:
	movement_direction = direction
	
func _on_pause_toggle() -> void:
	if Input_Manager.is_in_game():
		Input_Manager.enter_menu()
	else:
		Input_Manager.enter_game()
