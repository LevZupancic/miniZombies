extends Control

@export var dot_color: Color = Color.WHITE
@export var line_color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK

@export var line_length: int = 4
@export var line_gap: int = 8
@export var line_thickness: int = 2
@export var dot_enabled: bool = true
@export var outlines_enabled: bool = true

func _draw() -> void:
	var draw_to: int = line_gap + line_length
	# Outlines
	if (outlines_enabled):
		if (dot_enabled):
			draw_circle(Vector2.ZERO, 2.5, outline_color)
		draw_line(Vector2(line_gap-1, 0), Vector2(draw_to + 1, 0), outline_color, line_thickness + 2)
		draw_line(Vector2(-(line_gap-1), 0), Vector2(-draw_to - 1, 0), outline_color, line_thickness + 2)
		draw_line(Vector2(0, line_gap-1), Vector2(0, draw_to + 1), outline_color, line_thickness + 2)
		draw_line(Vector2(0,-(line_gap-1)), Vector2(0, -draw_to - 1), outline_color, line_thickness + 2)
	# Middle dot
	if (dot_enabled):
		draw_circle(Vector2.ZERO, 1, dot_color)
	# Lines
	draw_line(Vector2(line_gap, 0), Vector2(draw_to, 0), line_color, line_thickness)
	draw_line(Vector2(-line_gap, 0), Vector2(-draw_to, 0), line_color, line_thickness)
	draw_line(Vector2(0, line_gap), Vector2(0, draw_to), line_color, line_thickness)
	draw_line(Vector2(0, -line_gap), Vector2(0, -draw_to), line_color, line_thickness)
