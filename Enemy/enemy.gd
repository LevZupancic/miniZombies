class_name Enemy extends CharacterBody3D


const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var attack_range: float = 1.5
@export var max_hitpoints: int = 100
@export var attack_damage: int = 25

var player: Player
var provoked: bool = false
var aggro_range: float = 12.0
var hitpoints: int = max_hitpoints

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position

func _physics_process(delta: float) -> void:
	var next_position: Vector3 = navigation_agent_3d.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction: Vector3 =  global_position.direction_to(next_position)
	var distance: float = global_position.distance_to(player.global_position)
	
	if (distance < aggro_range):
		provoked = true
		
	if (distance < attack_range && provoked):
		animation_player.play("Attack")
	
	if direction:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func look_at_target(direction: Vector3) -> void:
	var adjusted_direction: Vector3 = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)
	
func attack() -> void:
	print("Attack!")
	player.take_damage(attack_damage)

func handle_death() -> void:
	queue_free()

func take_damage(damage: int) -> void:
		provoked = true # Automatically become agrro when hit
		hitpoints -= damage
		if (hitpoints < 0):
			handle_death()
