# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualField
extends Node2D

var field: SimField
var field_rect: Rect2
var outbounds_rect: Rect2

@onready var lines: Node2D = $Lines


func setup(p_field: SimField) -> void:
	field = p_field

	field_rect = Rect2(field.line_left, field.line_top, field.WIDTH, field.HEIGHT)
	outbounds_rect = field_rect.grow(500)

	# penalty area lines
	var penalty_area_line_left: Line2D = Line2D.new()
	penalty_area_line_left.width = field.LINE_WIDTH
	for point: Vector2 in field.penalty_areas.left:
		penalty_area_line_left.add_point(point)
	lines.add_child(penalty_area_line_left)

	var penalty_area_line_right: Line2D = Line2D.new()
	penalty_area_line_right.width = field.LINE_WIDTH
	for point: Vector2 in field.penalty_areas.right:
		penalty_area_line_right.add_point(point)
	lines.add_child(penalty_area_line_right)

	# middle line
	var middle_line: Line2D = Line2D.new()
	middle_line.width = field.LINE_WIDTH
	middle_line.add_point(Vector2(field.center.x, field.line_top))
	middle_line.add_point(Vector2(field.center.x, field.line_bottom))
	lines.add_child(middle_line)


func _draw() -> void:
	# outbound color
	draw_rect(outbounds_rect, Color.CADET_BLUE)

	# floor color
	draw_rect(field_rect, Color.ORANGE)

	# center circle
	draw_circle(field.center, field.CENTER_CIRCLE_RADIUS + field.LINE_WIDTH, Color.WHITE)
	draw_circle(field.center, field.CENTER_CIRCLE_RADIUS, Color.ORANGE)
	# center spot
	draw_circle(field.center, 3, Color.WHITE, true)
	# penalty 6m circle
	draw_circle(field.penalty_areas.spot_left, 3, Color.WHITE, true)
	draw_circle(field.penalty_areas.spot_right, 3, Color.WHITE, true)
	# penalty 10m circle
	draw_circle(field.penalty_areas.spot_10m_left, 3, Color.WHITE, true)
	draw_circle(field.penalty_areas.spot_10m_right, 3, Color.WHITE, true)

	# outer lines
	draw_line(
		Vector2(field.line_left, field.line_top),
		Vector2(field.line_right, field.line_top),
		Color.WHITE,
		field.LINE_WIDTH
	)
	draw_line(
		Vector2(field.line_right, field.line_top),
		Vector2(field.line_right, field.line_bottom),
		Color.WHITE,
		field.LINE_WIDTH
	)
	draw_line(
		Vector2(field.line_right, field.line_bottom),
		Vector2(field.line_left, field.line_bottom),
		Color.WHITE,
		field.LINE_WIDTH
	)
	draw_line(
		Vector2(field.line_left, field.line_top),
		Vector2(field.line_left, field.line_bottom),
		Color.WHITE,
		field.LINE_WIDTH
	)
