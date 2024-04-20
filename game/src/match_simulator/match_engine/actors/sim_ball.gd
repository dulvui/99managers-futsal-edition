# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall

signal corner
signal kick_in
signal goal

const deceleration = 0.01

var pos:Vector2
var speed:float
var direction:Vector2

var trajectory_polygon:PackedVector2Array
var players_in_shoot_trajectory:int
var empty_net:bool

func set_up(field:SimField) -> void:
	pos = field.center
	trajectory_polygon = PackedVector2Array()
	
func set_pos(p_pos:Vector2) -> void:
	pos = p_pos
	stop()

func update() -> void:
	if speed > 0:
		move()
	else:
		speed = 0

func move() -> void:
	pos += direction * speed
	speed -= deceleration

func is_moving() -> bool:
	return speed > 0
	
func stop() -> void:
	speed = 0

func kick(p_destination:Vector2, force:float) -> void:
	speed = force + 0.2 # ball moves a bit faster that the force is
	direction = pos.direction_to(p_destination)

func is_in_field(field:SimField) -> bool:
	return Geometry2D.is_point_in_polygon(pos, field.polygon)

func check_field_bounds(field:SimField) -> void:
	if is_in_field(field):
		return
	
	# kick in
	if pos.y < 0:
		set_pos(Vector2(pos.x, 0))
		kick_in.emit()
		return
	if pos.y > field.size.y:
		set_pos(Vector2(pos.x, field.size.y))
		kick_in.emit()
		return
	
	if pos.x < 0 or pos.x > field.size.x:
		# TODO check if post was hit => reflect
		if field.is_goal(pos):
			set_pos(field.center)
			goal.emit()
			return
		# corner
		else:
			var corner_pos:Vector2 = field.get_corner_pos(pos)
			set_pos(corner_pos)
			corner.emit()
			return
	