class_name Gun extends Weapon

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var starting_weapon_position: Vector3 = weapon_mesh.position
@export var muzzle_flash: GPUParticles3D

var fire_input_pressed: bool = false
var fire_input_just_pressed: bool = false

func _ready() -> void:
	Input_Manager.fire_requested.connect(_on_fire_requested)
	Input_Manager.fire_released.connect(_on_fire_released)

func _process(delta: float) -> void:
	# reset weapon position
	weapon_mesh.position = weapon_mesh.position.lerp(starting_weapon_position, delta * 10.0)
	
	if not Input_Manager.is_in_game():
		fire_input_pressed = false
		fire_input_just_pressed = false
		return
	
	if weapon_resource.fire_type == Weapon_Resource.FireType.AUTOMATIC:
		if fire_input_pressed and cooldown_timer.is_stopped():
			shoot()
	elif weapon_resource.fire_type == Weapon_Resource.FireType.SEMIAUTO:
		if fire_input_just_pressed and cooldown_timer.is_stopped():
			shoot()

	fire_input_just_pressed = false
	
func shoot() -> void:
	muzzle_flash.restart()
	cooldown_timer.start(1.0 / weapon_resource.firerate)
	# update weapon position based on recoil
	weapon_mesh.position.z += weapon_resource.recoil
	handle_hit()

## Signal handlers
func _on_fire_requested() -> void:
	fire_input_just_pressed = true
	fire_input_pressed = true

func _on_fire_released() -> void:
	fire_input_pressed = false

## Abstract functions
func handle_hit() -> void:
	pass
