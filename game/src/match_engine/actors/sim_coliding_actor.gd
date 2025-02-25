# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CollidingActor

var from: Vector2
var to: Vector2
var normal: Vector2


func _init(p_from: Vector2, p_to: Vector2) -> void:
	from = p_from
	to = p_to
	normal = from.direction_to(to)


func collides(p_from: Vector2, p_to: Vector2) -> Variant:
	if Geometry2D.segment_intersects_segment(from, to, p_from, p_to) == null:
		return null

	return p_from.direction_to(p_to).reflect(normal)
