# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MovingActor
extends CollidingActor


var pos: Vector2
var last_pos: Vector2
var next_pos: Vector2

var speed: float
var direction: Vector2


func set_pos(p_pos: Vector2) -> void:
	pos = p_pos
	stop()


func set_pos_xy(x: float, y: float) -> void:
	pos.x = x
	pos.y = y
	stop()


func move() -> void:
	if speed > 0:
		last_pos = pos
		pos = next_pos
		next_pos =  pos + (direction * speed * Const.SPEED)
	else:
		speed = 0


func is_moving() -> bool:
	return speed > 0


func stop() -> void:
	speed = 0
	last_pos = pos

