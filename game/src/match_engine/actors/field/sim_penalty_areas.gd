# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPenaltyAreas

var left: PackedVector2Array
var right: PackedVector2Array

var spot_left: Vector2
var spot_right: Vector2
var spot_10m_left: Vector2
var spot_10m_right: Vector2


func _init(field: SimField, goals: SimGoals) -> void:
	const RADIUS: int = 6 * field.PIXEL_FACTOR

	# penalty area
	left = PackedVector2Array()
	right = PackedVector2Array()

	# create upper circle for penalty area
	var points: int = 12
	var curve: Curve2D = Curve2D.new()

	# left
	var start_point: Vector2 = Vector2(goals.post_top_left)
	var end_point: Vector2 = Vector2(goals.post_top_left + Vector2(RADIUS, 0))

	for i: int in points:
		curve.add_point(start_point + Vector2(0, -RADIUS).rotated((i / float(points)) * PI / 2))
	curve.add_point(end_point)

	start_point = Vector2(goals.post_bottom_left)
	end_point = Vector2(goals.post_bottom_left + Vector2(0, RADIUS))

	for i: int in range(points, points + points):
		curve.add_point(start_point + Vector2(0, -RADIUS).rotated((i / float(points)) * PI / 2))
	curve.add_point(end_point)

	left.append_array(curve.get_baked_points())

	# right
	curve.clear_points()
	curve.add_point(end_point)

	for i: int in range(points * 2, points * 3):
		curve.add_point(start_point + Vector2(0, -RADIUS).rotated((i / float(points)) * PI / 2))
	curve.add_point(Vector2(goals.post_bottom_left - Vector2(RADIUS, 0)))

	start_point = Vector2(goals.post_top_left)
	end_point = Vector2(goals.post_top_left - Vector2(0, RADIUS))

	curve.add_point(Vector2(goals.post_top_left - Vector2(RADIUS, 0)))
	for i: int in range(points * 3, points * 4):
		curve.add_point(start_point + Vector2(0, -RADIUS).rotated((i / float(points)) * PI / 2))
	curve.add_point(end_point)

	right.append_array(curve.get_baked_points())

	# move to opposite site
	for i: int in right.size():
		right[i] += Vector2(field.WIDTH, 0)

	# caclulate penalty spots
	spot_left = Vector2(field.line_left + RADIUS, field.center.y)
	spot_right = Vector2(field.line_right - RADIUS, field.center.y)

	const SPOT_10_M: int = 10 * field.PIXEL_FACTOR
	spot_10m_left = Vector2(field.line_left + SPOT_10_M, field.center.y)
	spot_10m_right = Vector2(field.line_right - SPOT_10_M, field.center.y)
