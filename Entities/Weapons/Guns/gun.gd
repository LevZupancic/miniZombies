class_name Gun extends Weapon

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var starting_weapon_position: Vector3 = weapon_mesh.position
@export var muzzle_flash: GPUParticles3D

func _ready() -> void:
	pass
