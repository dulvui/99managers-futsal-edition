# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualField
extends Node2D

var field: SimField

@onready var lines: Node2D = $Lines


func _draw() -> void:
	# TODO use draw_rect
	# hack for field color
	draw_circle(field.center, field.WIDTH + field.HEIGHT, Color.ORANGE)
	# center circle
	draw_circle(field.center, field.CENTER_CIRCLE_RADIUS + field.LINE_WIDTH, Color.WHITE)
	draw_circle(field.center, field.CENTER_CIRCLE_RADIUS, Color.ORANGE)

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

	# goals
	draw_dashed_line(
		field.goals.post_top_left,
		field.goals.post_bottom_left,
		Color.FIREBRICK,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)
	draw_dashed_line(
		field.goals.post_top_right,
		field.goals.post_bottom_right,
		Color.FIREBRICK,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)


func setup(p_field: SimField) -> void:
	field = p_field

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
