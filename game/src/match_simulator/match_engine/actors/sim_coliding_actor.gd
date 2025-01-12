# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CollidingActor
extends Node


var pos: Vector2
var last_pos: Vector2
var next_pos: Vector2
var speed: float
var direction: Vector2


func collides(p_moving_actor: CollidingActor) -> Vector2:
	return Geometry2D.line_intersects_line(
		last_pos,
		pos,
		p_moving_actor.last_pos,
	    p_moving_actor.pos
	)


func will_collide(p_moving_actor: CollidingActor) -> Vector2:
	return Geometry2D.line_intersects_line(
		pos,
		next_pos,
		p_moving_actor.pos,
		p_moving_actor.next_pos
	)

