class_name GuiComponent extends Control

@onready var ammo_label: Label = %AmmoLabel

func change_ammo(mag: int, secondary: int) -> void:
	ammo_label.set_text(str(mag) + " / " + str(secondary))
