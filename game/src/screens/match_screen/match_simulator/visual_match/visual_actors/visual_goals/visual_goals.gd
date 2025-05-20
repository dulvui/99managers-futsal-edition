# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# needed to have goals on layer above field and ball
# to move ball between field and posts/net
class_name VisualGoals
extends Node2D

var field: SimField
var colors: StadiumColors


func _ready() -> void:
	# _draw gets called before setup, so default value needed
	colors = StadiumColors.new()


func setup(p_field: SimField, p_colors: StadiumColors = StadiumColors.new()) -> void:
	field = p_field
	colors = p_colors


func set_colors(p_colors: StadiumColors) -> void:
	colors = p_colors
	queue_redraw()


func _draw() -> void:
	# posts
	draw_line(
		field.goals.post_top_left,
		field.goals.post_bottom_left,
		colors.goal_1,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)
	draw_line(
		field.goals.post_top_right,
		field.goals.post_bottom_right,
		colors.goal_1,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)
	draw_dashed_line(
		field.goals.post_top_left,
		field.goals.post_bottom_left,
		colors.goal_2,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)
	draw_dashed_line(
		field.goals.post_top_right,
		field.goals.post_bottom_right,
		colors.goal_2,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)

	# net vertical
	for i: int in range(1, 9):
		draw_line(
			field.goals.post_top_left - Vector2(i * 5, 0),
			field.goals.post_bottom_left - Vector2(i * 5, 0),
			colors.goal_1,
			field.LINE_WIDTH * .2,
			field.LINE_WIDTH * .2
		)
		draw_line(
			field.goals.post_top_right + Vector2(i * 5, 0),
			field.goals.post_bottom_right + Vector2(i * 5, 0),
			colors.goal_1,
			field.LINE_WIDTH * .2,
			field.LINE_WIDTH * .2
		)

	# net horizontal
	for i: int in range(0, 18):
		draw_line(
			field.goals.post_top_left + Vector2(-40, i * 5),
			field.goals.post_top_left + Vector2(-3, i * 5),
			colors.goal_1,
			field.LINE_WIDTH * .2,
			field.LINE_WIDTH * .2
		)
		draw_line(
			field.goals.post_top_right + Vector2(40, i * 5),
			field.goals.post_top_right + Vector2(3, i * 5),
			colors.goal_1,
			field.LINE_WIDTH * .2,
			field.LINE_WIDTH * .2
		)

