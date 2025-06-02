class_name Hitscan_Weapon extends Node3D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var starting_weapon_position: Vector3 = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@export var fire_rate: float = 15.0
@export var recoil: float = 0.05
@export var weapon_mesh: Node3D
@export var weapon_damage: int = 15
@export var automatic: bool = true
@export var muzzle_flash: GPUParticles3D
@export var sparks: PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if automatic:
		if Input.is_action_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	else:
		if Input.is_action_just_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	
	weapon_mesh.position = weapon_mesh.position.lerp(starting_weapon_position, delta * 10.0)

func shoot() -> void:
	muzzle_flash.restart()
	cooldown_timer.start(1.0 / fire_rate)
	weapon_mesh.position.z += recoil
	handle_hit()

func handle_hit() -> void:
	var collider: Object = ray_cast_3d.get_collider()
	printt("Fired!", collider)
	if (collider is Enemy):
		collider.take_damage(weapon_damage)
	var spark: GPUParticles3D = sparks.instantiate()
	add_child(spark)
	spark.global_position = ray_cast_3d.get_collision_point()
