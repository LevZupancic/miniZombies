class_name Player extends CharacterBody3D


const SPEED: float = 5.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation: AnimationPlayer = $ScreenEffectController/DamageTexture/DamageAnimation
@onready var hit_animation: AnimationPlayer = $ScreenEffectController/HitTexture/HitAnimation
@onready var game_over_menu: GameOverMenu = $GameOverMenu

@export var jump_height: float = 1.0
@export var max_hitpoints: int = 100

var speed_multi: float = 1.0
var mouse_motion: Vector2 = Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var hitpoints: int = max_hitpoints

func _ready() -> void:
	# Locks the mouse to screen, so you don't go off screen, and will always listen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	# Add the gravity
	if not is_on_floor():
		var fall_multiplier: float = 2.0 if velocity.y < 0 else 1.0
		velocity += get_gravity() * delta * fall_multiplier

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		
	# Handle sprint
	if Input.is_action_pressed("sprint") and is_on_floor():
		speed_multi = 2.0
	else: 
		speed_multi = 1.0
		
	var speed: float = SPEED * speed_multi
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	# TODO should be separate manager for input handling
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			mouse_motion = -event.relative * 0.005
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

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
	game_over_menu.game_over()
