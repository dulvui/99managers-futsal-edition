# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPenaltyAreas


var home: PackedVector2Array
var away: PackedVector2Array


func _init(field: SimField, goals: SimGoals) -> void:

	const PANALTY_AREA_RADIUS: int = 5 * field.PIXEL_FACTOR

	# penalty area
	home = PackedVector2Array()
	away = PackedVector2Array()

	# create upper circle for penalty area
	var points: int = 12
	var curve: Curve2D = Curve2D.new()

	# left
	var start_point: Vector2 = Vector2(goals.post_top_left)
	var end_point: Vector2 = Vector2(goals.post_top_left + Vector2(PANALTY_AREA_RADIUS, 0))

	for i: int in points:
		curve.add_point(
			start_point + Vector2(0, -PANALTY_AREA_RADIUS).rotated((i / float(points)) * PI / 2)
		)
	curve.add_point(end_point)

	start_point = Vector2(goals.post_bottom_left)
	end_point = Vector2(goals.post_bottom_left + Vector2(0, PANALTY_AREA_RADIUS))

	for i: int in range(points, points + points):
		curve.add_point(
			start_point + Vector2(0, -PANALTY_AREA_RADIUS).rotated((i / float(points)) * PI / 2)
		)
	curve.add_point(end_point)

	home.append_array(curve.get_baked_points())

	# right
	curve.clear_points()
	curve.add_point(end_point)

	for i: int in range(points * 2, points * 3):
		curve.add_point(
			start_point + Vector2(0, -PANALTY_AREA_RADIUS).rotated((i / float(points)) * PI / 2)
		)
	curve.add_point(Vector2(goals.post_bottom_left - Vector2(PANALTY_AREA_RADIUS, 0)))

	start_point = Vector2(goals.post_top_left)
	end_point = Vector2(goals.post_top_left - Vector2(0, PANALTY_AREA_RADIUS))

	curve.add_point(Vector2(goals.post_top_left - Vector2(PANALTY_AREA_RADIUS, 0)))
	for i: int in range(points * 3, points * 4):
		curve.add_point(
			start_point + Vector2(0, -PANALTY_AREA_RADIUS).rotated((i / float(points)) * PI / 2)
		)
	curve.add_point(end_point)

	away.append_array(curve.get_baked_points())

	# move to opposite site
	for i in away.size():
		away[i] += Vector2(field.WIDTH, 0)


