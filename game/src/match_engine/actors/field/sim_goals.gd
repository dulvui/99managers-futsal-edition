# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimGoals

signal post_hit_left
signal post_hit_right

const SIZE: int = 3 * SimField.PIXEL_FACTOR

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

# colission only on 3 sides, since ball can't hot post from behind
var post_top_left_top: CollidingActor
var post_top_left_right: CollidingActor
var post_top_left_bottom: CollidingActor

var post_top_right_top: CollidingActor
var post_top_right_left: CollidingActor
var post_top_right_bottom: CollidingActor

var post_bottom_left_top: CollidingActor
var post_bottom_left_right: CollidingActor
var post_bottom_left_bottom: CollidingActor

var post_bottom_right_top: CollidingActor
var post_bottom_right_left: CollidingActor
var post_bottom_right_bottom: CollidingActor


func _init(field: SimField) -> void:

	left = Vector2(field.line_left, field.size.y / 2)
	right = Vector2(field.line_right, field.size.y / 2)

	post_bottom = int(field.size.y / 2.0) + int(SIZE / 2.0)
	post_top = int(field.size.y / 2.0) - int(SIZE / 2.0)

	post_top_left = Vector2(field.line_left, post_top)
	post_bottom_left = Vector2(field.line_left, post_bottom)
	post_top_right = Vector2(field.line_right, post_top)
	post_bottom_right = Vector2(field.line_right, post_bottom)

	# colissions
	var post_size: float = 1.0 * SimField.PIXEL_FACTOR

	# top left
	post_top_left_top = (
		CollidingActor
		. new(
			post_top_left + Vector2(-post_size, -post_size),
			post_top_left + Vector2(0, -post_size),
		)
	)
	post_top_left_right = (
		CollidingActor
		. new(
			post_top_left + Vector2(0, -post_size),
			post_top_left + Vector2(0, 0),
		)
	)
	post_top_left_bottom = (
		CollidingActor
		. new(
			post_top_left + Vector2(0, 0),
			post_top_left + Vector2(-post_size, 0),
		)
	)
	# top right
	post_top_right_top = (
		CollidingActor
		. new(
			post_top_right + Vector2(post_size, post_size),
			post_top_right + Vector2(0, post_size),
		)
	)
	post_top_right_left = (
		CollidingActor
		. new(
			post_top_right + Vector2(0, post_size),
			post_top_right + Vector2(0, 0),
		)
	)
	post_top_right_bottom = (
		CollidingActor
		. new(
			post_top_right + Vector2(0, 0),
			post_top_right + Vector2(post_size, 0),
		)
	)

	# bottom left
	post_bottom_left_top = (
		CollidingActor
		. new(
			post_bottom_left + Vector2(-post_size, 0),
			post_bottom_left + Vector2(0, 0),
		)
	)
	post_bottom_left_right = (
		CollidingActor
		. new(
			post_bottom_left + Vector2(0, 0),
			post_bottom_left + Vector2(0, -post_size),
		)
	)
	post_bottom_left_bottom = (
		CollidingActor
		. new(
			post_bottom_left + Vector2(0, -post_size),
			post_bottom_left + Vector2(-post_size, -post_size),
		)
	)
	# bottom right
	post_bottom_right_top = (
		CollidingActor
		. new(
			post_bottom_right + Vector2(post_size, 0),
			post_bottom_right + Vector2(0, 0),
		)
	)
	post_bottom_right_left = (
		CollidingActor
		. new(
			post_bottom_right + Vector2(0, 0),
			post_bottom_right + Vector2(0, post_size),
		)
	)
	post_bottom_right_bottom = (
		CollidingActor
		. new(
			post_bottom_right + Vector2(0, post_size),
			post_bottom_right + Vector2(post_size, post_size),
		)
	)


func is_goal_right(ball: SimBall) -> bool:
	var intersection: Variant = Geometry2D.segment_intersects_segment(
		ball.last_pos, ball.pos, post_bottom_right, post_top_right
	)

	if intersection and intersection.y < post_bottom and intersection.y > post_top:
		return true
	return false


func is_goal_left(ball: SimBall) -> bool:
	var intersection: Variant = Geometry2D.segment_intersects_segment(
		ball.last_pos, ball.pos, post_bottom_left, post_top_left
	)

	if intersection and intersection.y < post_bottom and intersection.y > post_top:
		return true
	return false


func check_post_colissions(ball: SimBall) -> void:
	var reflection: Variant

	# left
	if ball.direction.x < 0:
		# can always hit right side of post
		reflection = post_top_left_right.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			post_hit_left.emit()
			return
		reflection = post_bottom_left_right.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			post_hit_left.emit()
			return
		# up
		if ball.direction.y < 0:
			reflection = post_top_left_bottom.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_left.emit()
				return
			reflection = post_bottom_left_bottom.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_left.emit()
				return
		# down
		else:
			reflection = post_top_left_top.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_left.emit()
				return
			reflection = post_bottom_left_top.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_left.emit()
				return
	# right
	else:
		# can always hit left side of post
		reflection = post_top_right_left.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			post_hit_right.emit()
			return
		reflection = post_bottom_right_left.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			post_hit_right.emit()
			return
		# up
		if ball.direction.y < 0:
			reflection = post_top_right_bottom.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_right.emit()
				return
			reflection = post_bottom_right_bottom.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_right.emit()
				return
		# down
		else:
			reflection = post_top_right_top.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_right.emit()
				return
			reflection = post_bottom_right_top.collides(ball.last_pos, ball.pos)
			if reflection != null:
				ball.direction = reflection
				post_hit_right.emit()
				return

