class_name Weapon extends Node3D

@export var weapon_resource: Weapon_Resource
@export var weapon_mesh: Node3D

func set_active(_active: bool) -> void:
	# Override in child classes for weapon-specific activation logic
	pass
