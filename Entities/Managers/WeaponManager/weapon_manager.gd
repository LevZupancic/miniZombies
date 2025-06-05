extends Node3D

@export var weapon_1: Hitscan_Weapon
@export var weapon_2: Hitscan_Weapon

# TODO save reference to currently equiped so you don't loop everytime
# TODO Maybe change this manager to Inventory manager ? 

func equip(active_weapon: Hitscan_Weapon) -> void:
	for child: Hitscan_Weapon in get_children():
		if child == active_weapon:
			child.visible = true
			child.set_process(true)
		else:
			child.visible = false
			child.set_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("num_1"):
		equip(weapon_1)
	elif event.is_action_pressed("num_2"):
		equip(weapon_2)
	
