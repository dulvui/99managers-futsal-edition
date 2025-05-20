# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualField
extends Node2D

var field: SimField
var colors: StadiumColors
var field_rect: Rect2
var outbounds_rect: Rect2


func _ready() -> void:
	colors = StadiumColors.new()
	# assuming fields are always the same size
	# if in future fields have different sizes, this needs to be called as setup with redraw
	field = SimField.new()

	field_rect = Rect2(field.line_left, field.line_top, field.WIDTH, field.HEIGHT)
	outbounds_rect = field_rect.grow(500)


func set_colors(p_colors: StadiumColors) -> void:
	colors = p_colors
	queue_redraw()


func _draw() -> void:
	# outbound color
	draw_rect(outbounds_rect, colors.outbound, true, true)

	# floor color
	draw_rect(field_rect, colors.floorz, true, true)

	# center circle
	draw_circle(field.center, field.CENTER_CIRCLE_RADIUS, colors.center_circle, true, -1.0, true)
	# center circle line
	draw_circle(
		field.center, field.CENTER_CIRCLE_RADIUS, colors.line, false, field.LINE_WIDTH, true
	)

	# penalty areas
	draw_colored_polygon(field.penalty_areas.left, colors.center_circle)
	draw_colored_polygon(field.penalty_areas.right, colors.center_circle)

	# center spot
	draw_circle(field.center, 3, colors.line, true, -1.0, true)
	# penalty 6m circle
	draw_circle(field.penalty_areas.spot_left, 3, colors.line, true, -1.0, true)
	draw_circle(field.penalty_areas.spot_right, 3, colors.line, true, -1.0, true)
	# penalty 10m circle
	draw_circle(field.penalty_areas.spot_10m_left, 3, colors.line, true, -1.0, true)
	draw_circle(field.penalty_areas.spot_10m_right, 3, colors.line, true, -1.0, true)

	# lines
	draw_multiline(
		[
			# outer lines
			Vector2(field.line_left, field.line_top),
			Vector2(field.line_right, field.line_top),
			Vector2(field.line_right, field.line_top),
			Vector2(field.line_right, field.line_bottom),
			Vector2(field.line_right, field.line_bottom),
			Vector2(field.line_left, field.line_bottom),
			Vector2(field.line_left, field.line_top),
			Vector2(field.line_left, field.line_bottom),
			# middle line
			Vector2(field.center.x, field.line_top),
			Vector2(field.center.x, field.line_bottom),
		],
		colors.line,
		field.LINE_WIDTH,
		true
	)

	# penalty areas lines
	draw_polyline(field.penalty_areas.left, colors.line, field.LINE_WIDTH, true)
	draw_polyline(field.penalty_areas.right, colors.line, field.LINE_WIDTH, true)

