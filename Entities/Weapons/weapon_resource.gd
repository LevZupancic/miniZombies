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

enum FireType {
	DEFAULT = 0,
	AUTOMATIC = 1,
	SEMIAUTO = 2,
}

enum WeaponType {
	DEFAULT = 0,
	GUN = 1,
	KNIFE = 2,
	THROWABLE = 3,
	SPECIAL = 4
}
