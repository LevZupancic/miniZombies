class_name Weapon_Resource extends Resource

@export var name: String
@export var weapon_type: WeaponType
@export var fire_type: FireType

@export var damage: int
@export var firerate: float
@export var recoil: float
@export var mag_size: int
@export var max_ammo: int
@export var price: int
@export var swap_time: float
@export var reload_time: float

enum FireType {
	AUTOMATIC = 0,
	SEMIAUTO = 1,
}

enum WeaponType {
	GUN = 0,
	KNIFE = 1,
	THROWABLE = 2,
	SPECIAL = 3
}
