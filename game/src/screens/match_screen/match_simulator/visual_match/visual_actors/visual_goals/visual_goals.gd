# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# needed to have goals on layer above field and ball
# to move ball between field and posts/net
class_name VisualGoals
extends Node2D

var field: SimField
var colors: StadiumColors


func _ready() -> void:
	colors = StadiumColors.new()
	# assuming fields are always the same size
	# if in future fields have different sizes, this needs to be called as setup with redraw
	field = SimField.new()


func set_colors(p_colors: StadiumColors) -> void:
	colors = p_colors
	queue_redraw()


func _draw() -> void:
	# posts
	draw_multiline(
		[
			field.goals.post_top_left,
			field.goals.post_bottom_left,
			field.goals.post_top_right,
			field.goals.post_bottom_right,
		],
		colors.goal_1,
		field.LINE_WIDTH * 1.5,
		true
	)
	draw_dashed_line(
		field.goals.post_top_left,
		field.goals.post_bottom_left,
		colors.goal_2,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5,
		true,
		true
	)
	draw_dashed_line(
		field.goals.post_top_right,
		field.goals.post_bottom_right,
		colors.goal_2,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5,
		true,
		true
	)

	# net lines
	var net_points: PackedVector2Array = PackedVector2Array()

	# vertical lines
	for i: int in range(1, 9):
		net_points.append(field.goals.post_top_left - Vector2(i * 5, 0))
		net_points.append(field.goals.post_bottom_left - Vector2(i * 5, 0))
		net_points.append(field.goals.post_top_right + Vector2(i * 5, 0))
		net_points.append(field.goals.post_bottom_right + Vector2(i * 5, 0))

	# net horizontal
	for i: int in range(0, 18):
		net_points.append(field.goals.post_top_left + Vector2(-40, i * 5))
		net_points.append(field.goals.post_top_left + Vector2(-3, i * 5))
		net_points.append(field.goals.post_top_right + Vector2(40, i * 5))
		net_points.append(field.goals.post_top_right + Vector2(3, i * 5))

	draw_multiline(
		net_points,
		colors.line,
		field.LINE_WIDTH * .3,
		true
	)

