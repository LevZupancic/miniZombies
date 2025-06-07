class_name InventoryManager extends Node3D

const TAG: String = "[InventoryManager]"
# Weapon ranges per category, should not be empty!
const GUN_SLOTS: Array[int] = [WeaponSlot.MAIN_1, WeaponSlot.MAIN_2]
const KNIFE_SLOTS: Array[int] = [WeaponSlot.KNIFE]
const THROWABLE_SLOTS: Array[int] = [WeaponSlot.THROWABLE_1, WeaponSlot.THROWABLE_2, WeaponSlot.THROWABLE_3, WeaponSlot.THROWABLE_4]
const SPECIAL_SLOTS: Array[int] = [WeaponSlot.SPECIAL_1, WeaponSlot.SPECIAL_2]

var weapons: Array[Weapon]
var current_weapon: Weapon
var current_slot: WeaponSlot

enum WeaponSlot {
	UNDEFINED = -1,
	MAIN_1 = 0,
	MAIN_2 = 1,
	KNIFE = 2,
	THROWABLE_1 = 3,
	THROWABLE_2 = 4,
	THROWABLE_3 = 5,
	THROWABLE_4 = 6,
	SPECIAL_1 = 7,
	SPECIAL_2 = 8,
}

func _ready() -> void:
	weapons = [null, null, null, null, null, null, null, null, null]
	equip_slot(WeaponSlot.MAIN_1)
	current_slot = WeaponSlot.MAIN_1
	
func _unhandled_input(event: InputEvent) -> void:
	# TODO Create separate input controller
	for i: int in range(1, 10):
		if event.is_action_pressed("num_" + str(i)):
			var weapon_slot: int = i - 1
			if weapon_slot != current_slot:
				equip_slot(weapon_slot as WeaponSlot)
				return
	if event is InputEventMouseButton:
		print(TAG, " got InputEventMouseButton")
		if event.pressed:
			print(TAG, " event.pressed")

	if event.is_action_pressed("mouse_wheel_up"):
		print(TAG, " got scroll up")
		equip_slot(get_next_weapon_slot(1))
		return
	if event.is_action_pressed("mouse_wheel_down"):
		print(TAG, " got scroll down")
		equip_slot(get_next_weapon_slot(-1))
		return

func equip_slot(slot: WeaponSlot) -> void:
	var weapon = weapons[slot]
	if weapon:
		print(TAG, " Successfully equipping weapon in slot: ", slot)
		current_slot = slot
		equip_weapon(weapon)
	else: 
		print(TAG, " No weapon in slot: ", slot)

func equip_weapon(weapon: Weapon) -> void:	
	if current_weapon:
		current_weapon.visible = false
		current_weapon.set_process(false)
		current_weapon.set_active(false)
	
	current_weapon = weapon
	weapon.visible = true
	weapon.set_process(true)
	weapon.set_active(true)

func get_next_weapon_slot(direction: int) -> WeaponSlot:
	var weapons_size: int = weapons.size()
	var next_weapon: int = current_slot
	
	for i: int in range(weapons_size):
		next_weapon = wrapi(next_weapon + direction, 0, weapons_size)
		if (weapons[next_weapon] != null):
			return next_weapon as WeaponSlot
	return current_slot


func instantiate_weapon(weapon_scene: PackedScene) -> void:
	var existing_weapon: Weapon = find_weapon_by_scene(weapon_scene)
	if existing_weapon:
		print(TAG, " Weapon already exists: ", existing_weapon)
		equip_slot(get_weapon_slot(existing_weapon))
		return
		
	var weapon_instance = weapon_scene.instantiate() as Weapon
	if weapon_instance:
		add_weapon(weapon_instance)
	else:
		printerr(TAG, " Error: Could not instantiate weapon")

func add_weapon(weapon: Weapon) -> void:
	if not weapon or not weapon.weapon_resource:
		print(TAG, " Error: Invalid weapon or missing weapon_resource")
		return
		
	weapon.visible = false
	weapon.set_process(false)
	add_child(weapon)
	
	var assigned_slot = find_available_slot(weapon.weapon_resource.weapon_type)
	weapons[assigned_slot] = weapon
	equip_slot(assigned_slot)

func find_available_slot(weapon_type: Weapon_Resource.WeaponType) -> WeaponSlot:
	var slot_range = get_slot_range_for_type(weapon_type)
	
	# When there is an empty space
	for i in slot_range:
		if weapons[i] == null:
			return i as WeaponSlot
	
	# Replacement logic
	var replace_slot: WeaponSlot
	if (current_weapon && weapon_type == current_weapon.weapon_resource.weapon_type):
		replace_slot = current_slot
	else:
		replace_slot = slot_range.back()
	
	remove_weapon(replace_slot)
	return replace_slot

func remove_weapon(weapon_slot: WeaponSlot) -> void:
	var weapon = weapons[weapon_slot]
	if weapon && is_instance_valid(weapon):
		weapon.queue_free()
	weapons[weapon_slot] = null
	
func get_slot_range_for_type(weapon_type: Weapon_Resource.WeaponType) -> Array[int]:
	match weapon_type:
		Weapon_Resource.WeaponType.GUN:
			return GUN_SLOTS
		Weapon_Resource.WeaponType.KNIFE:
			return KNIFE_SLOTS
		Weapon_Resource.WeaponType.THROWABLE:
			return THROWABLE_SLOTS
		Weapon_Resource.WeaponType.SPECIAL:
			return SPECIAL_SLOTS
		_:
			printerr(TAG, " Got unknown WeaponType")
			return []

func find_weapon_by_scene(scene: PackedScene) -> Weapon:
	for weapon: Weapon in weapons:
		if weapon && weapon.scene_file_path == scene.resource_path:
			return weapon
	return null

func get_weapon_slot(weapon: Weapon) -> WeaponSlot:
	for i: int in range(weapons.size()):
		if weapons[i] == weapon:
			return i as WeaponSlot
	return -1 as WeaponSlot


## Utility functions
func get_current_weapon() -> Weapon:
	return current_weapon

func get_current_slot() -> int:
	return current_slot
