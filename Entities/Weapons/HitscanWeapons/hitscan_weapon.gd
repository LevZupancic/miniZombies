class_name Hitscan_Weapon extends Node3D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var starting_weapon_position: Vector3 = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@export var weapon_resource: Weapon_Resource

@export var weapon_mesh: Node3D
@export var muzzle_flash: GPUParticles3D
@export var sparks: PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if weapon_resource.fire_type ==  Weapon_Resource.FireType.AUTOMATIC:
		if Input.is_action_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	elif weapon_resource.fire_type ==  Weapon_Resource.FireType.SEMIAUTO:
		if Input.is_action_just_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	# reset weapon position
	weapon_mesh.position = weapon_mesh.position.lerp(starting_weapon_position, delta * 10.0)

func shoot() -> void:
	muzzle_flash.restart()
	cooldown_timer.start(1.0 / weapon_resource.firerate)
	# update weapon position based on recoil
	weapon_mesh.position.z += weapon_resource.recoil
	handle_hit()

func handle_hit() -> void:
	var collider: Object = ray_cast_3d.get_collider()
	printt("Fired!", collider)
	if (collider is Enemy):
		collider.take_damage(weapon_resource.damage)
	if (collider != null):
		var spark: GPUParticles3D = sparks.instantiate()
		add_child(spark)
		spark.global_position = ray_cast_3d.get_collision_point()
