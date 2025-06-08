class_name Gun extends Weapon

const TAG: String = "[Gun]"

enum GunState {
	IDLE,
	FIRING, # Shot and is on cooldown
	RELOADING,
	SWAPPING
}

@onready var shoot_cooldown_timer: Timer = %ShootCooldownTimer
@onready var reload_timer: Timer = %ReloadTimer
@onready var starting_weapon_position: Vector3 = weapon_mesh.position
@export var muzzle_flash: GPUParticles3D

var current_state: GunState
var fire_input_pressed: bool
var fire_input_just_pressed: bool
var mag_ammo: int
var reserve_ammo: int

func _ready() -> void:
	Input_Manager.fire_requested.connect(_on_fire_requested)
	Input_Manager.fire_released.connect(_on_fire_released)
	Input_Manager.reload_requested.connect(_on_reload_requested)
	# Handle initialization
	enter_idle()
	mag_ammo = weapon_resource.mag_size
	reserve_ammo = weapon_resource.max_ammo
	fire_input_pressed = false
	fire_input_just_pressed = false

func _process(delta: float) -> void:
	# reset weapon position
	weapon_mesh.position = weapon_mesh.position.lerp(starting_weapon_position, delta * 10.0)
	if not Input_Manager.is_in_game():
		fire_input_pressed = false
		fire_input_just_pressed = false
		return
	
	if fire_input_pressed:
		if current_state == GunState.IDLE && mag_ammo > 0:
			handle_fire()
		fire_input_just_pressed = false
		
func handle_fire():
	if weapon_resource.fire_type == Weapon_Resource.FireType.AUTOMATIC:
			shoot()
	elif weapon_resource.fire_type == Weapon_Resource.FireType.SEMIAUTO:
		if fire_input_just_pressed:
			shoot()
	
	
func shoot() -> void:
	enter_firing()
	mag_ammo -= 1
	muzzle_flash.restart()
	shoot_cooldown_timer.start(1.0 / weapon_resource.firerate)
	# update weapon position based on recoil
	weapon_mesh.position.z += weapon_resource.recoil
	handle_hit()

func start_reload() -> void:
	enter_reloading()
	reload_timer.start(weapon_resource.reload_time)

func reload() -> void:
	if reserve_ammo > weapon_resource.mag_size:
		reserve_ammo -= (weapon_resource.mag_size - mag_ammo)
		mag_ammo = weapon_resource.mag_size
	else:
		mag_ammo = reserve_ammo
		reserve_ammo = 0
	print(TAG, " Reloaded, mag: ", mag_ammo, ", reserve: ", reserve_ammo)
	enter_idle()

## Weapon overrides
func handle_active() -> void:
	print(TAG, " Became active: ", weapon_resource.name)
	enter_idle()

func handle_inactive() -> void:
	shoot_cooldown_timer.stop()
	reload_timer.stop()
	enter_swapping()
	print(TAG, " Became inactive: ", weapon_resource.name)
	
## State handlers
func enter_firing() -> void:
	print(TAG, " Entered firing ", weapon_resource.name)
	current_state = GunState.FIRING

func enter_idle() -> void:
	print(TAG, " Entered idle ", weapon_resource.name)
	print(TAG, " AMMO, mag: ", mag_ammo, ", reserve: ", reserve_ammo)
	current_state = GunState.IDLE

func enter_reloading() -> void:
	print(TAG, " Entered Reloading ", weapon_resource.name)
	current_state = GunState.RELOADING

func enter_swapping() -> void:
	print(TAG, " Entered Swapping ", weapon_resource.name)
	current_state = GunState.SWAPPING

## Abstract functions
func handle_hit() -> void:
	pass

## Signal handlers
func _on_fire_requested() -> void:
	if weapon_active && current_state == GunState.IDLE:
		fire_input_just_pressed = true
		fire_input_pressed = true

func _on_fire_released() -> void:
	if weapon_active:
		fire_input_pressed = false

func _on_reload_requested() -> void:
	if weapon_active && current_state == GunState.IDLE && reserve_ammo > 0:
		start_reload()

func _on_shoot_cooldown_timer_timeout() -> void:
	if weapon_active && current_state == GunState.FIRING:
		enter_idle()

func _on_reload_timer_timeout() -> void:
	if weapon_active && current_state == GunState.RELOADING:
		reload()
