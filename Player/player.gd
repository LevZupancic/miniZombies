extends CharacterBody3D


const SPEED = 5.0
var speed_multi: float = 1.0
@export var jump_height: float = 1.0
var mouse_motion := Vector2.ZERO

@onready var camera_pivot: Node3D = $CameraPivot
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Locks the mouse to screen, so you don't go off screen, and will always listen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	# Add the gravity
	if not is_on_floor():
		var fall_multiplier = 3.0 if velocity.y < 0 else 1.0
		velocity += get_gravity() * delta * fall_multiplier

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		
	# Handle sprint
	if Input.is_action_pressed("sprint") and is_on_floor():
		speed_multi = 2.0
	else: 
		speed_multi = 1.0
		
	var speed = SPEED * speed_multi
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
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
