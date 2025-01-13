# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimGoals

var size: int
var left: Vector2
var right: Vector2

# y coordinates of goal posts
var post_top: int
var post_bottom: int

# x,y coordinates of all goal posts
var post_top_left: Vector2
var post_top_right: Vector2

var post_bottom_left: Vector2
var post_bottom_right: Vector2


func _init(field: SimField) -> void:
	size = 3 * field.PIXEL_FACTOR

	left = Vector2(field.line_left, field.size.y / 2)
	right = Vector2(field.line_right, field.size.y / 2)

	post_bottom = (field.size.y / 2) + (size / 2)
	post_top = (field.size.y / 2) - (size / 2)

	post_top_left = Vector2(field.line_left, post_top)
	post_bottom_left = Vector2(field.line_left, post_bottom)
	post_top_right = Vector2(field.line_right, post_top)
	post_bottom_right = Vector2(field.line_right, post_bottom)


func is_goal(ball: SimBall) -> Variant:
	var intersection: Variant

	# left
	if ball.direction.x < 0:
		intersection = Geometry2D.segment_intersects_segment(
			ball.last_pos, ball.pos, post_bottom_left, post_top_left
		)
	# right
	else:
		intersection = Geometry2D.segment_intersects_segment(
			ball.last_pos, ball.pos, post_bottom_right, post_top_right
		)

	if intersection and intersection.y < post_bottom and intersection.y > post_top:
		return intersection
	return null

