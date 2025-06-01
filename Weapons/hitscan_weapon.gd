class_name Hitscan_Weapon extends Node3D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var starting_weapon_position: Vector3 = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@export var fire_rate: float = 15.0
@export var recoil: float = 0.05
@export var weapon_mesh: Node3D
@export var weapon_damage: int = 15

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed("fire"):
		if cooldown_timer.is_stopped():
			shoot()
	weapon_mesh.position = weapon_mesh.position.lerp(starting_weapon_position, delta * 10.0)

func shoot() -> void:
	cooldown_timer.start(1.0 / fire_rate)
	var collider = ray_cast_3d.get_collider()
	printt("Fired!", collider)
	weapon_mesh.position.z += recoil
	if (collider is Enemy):
		collider.take_damage(weapon_damage)
