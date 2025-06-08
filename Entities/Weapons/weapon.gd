class_name Weapon extends Node3D

@export var weapon_resource: Weapon_Resource
@export var weapon_mesh: Node3D

var weapon_active: bool = false

func set_active(active: bool) -> void:
	weapon_active = active
	handle_active(active)

func handle_active(active: bool) -> void:
	pass
