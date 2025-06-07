class_name Hitscan_Gun extends Gun

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@export var sparks: PackedScene

func handle_hit() -> void:
	var collider: Object = ray_cast_3d.get_collider()
	printt("Fired!", collider)
	if (collider == null):
		return
	if (collider is Enemy):
		collider.take_damage(weapon_resource.damage)
	# Handle bullet holes/sparks
	var spark: GPUParticles3D = sparks.instantiate()
	add_child(spark)
	spark.global_position = ray_cast_3d.get_collision_point()
