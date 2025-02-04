# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualGoals
extends Node2D

var field: SimField


func setup(p_field: SimField) -> void:
	field = p_field


func _draw() -> void:
	draw_line(
		field.goals.post_top_left,
		field.goals.post_bottom_left,
		Color.WHITE,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)
	draw_line(
		field.goals.post_top_right,
		field.goals.post_bottom_right,
		Color.WHITE,
		field.LINE_WIDTH * 1.5,
		field.LINE_WIDTH * 1.5
	)
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


