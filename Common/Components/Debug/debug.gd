class_name Debug extends Control

const fps_ms: float = 16.0

@onready var container: VBoxContainer = %VBoxContainer
@export var enabled: bool = true

var properties: Array

func _ready() -> void:
	Global.debug = self
	visible = enabled

func add_debug_property(id: StringName, value, time_in_frames) -> void:
	if properties.has(id):
		if Time.get_ticks_msec() / fps_ms % time_in_frames == 0:
			var target = container.find_child(id, true, false) as Label
			target.text = id + ": " + str(value)
	else:
		var property = Label.new()
		container.add_child(property)
		property.name = id
		property.text = id + ": " + str(value)
		properties.append(id)
