# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MovingActor

var pos: Vector2
var last_pos: Vector2
var next_pos: Vector2

var direction: Vector2
var destination: Vector2

var follow_actor: MovingActor
# to keep distance to following object, squared for performance
var follow_distance_squared: float

var collision_radius: float
var force: float
var friction: float

var can_move: bool
var can_collide: bool


func _init(p_collision_radius: float, p_friction: float) -> void:
	can_move = true
	can_collide = true
	# collision_radius = pow(p_collision_radius, 2)
	collision_radius = p_collision_radius
	friction = p_friction

	_reset_movents()


func move() -> void:
	if force > 0:
		last_pos = pos
		pos = next_pos

		# set destination to following actor, if set
		if follow_actor	!= null and destination != follow_actor.pos:
			destination = follow_actor.pos
			direction = pos.direction_to(destination)

		# check destination reached, if set
		if destination != Vector2.INF:
			if destination_reached():
				stop()

		# actually move
		if direction != Vector2.INF:
			next_pos += direction * force * Const.SPEED

		# reduce force by friction:
		force -= friction

	else:
		stop()


func set_pos(p_pos: Vector2) -> void:
	pos = p_pos
	stop()


func set_pos_xy(x: float, y: float) -> void:
	pos.x = x
	pos.y = y
	stop()


func set_destination(p_pos: Vector2, p_force: float = 10) -> void:
	_reset_movents()
	destination = p_pos
	force = p_force
	direction = pos.direction_to(destination)


func follow(p_follow_actor: MovingActor, p_force: float = 10, p_distance_squared: float = 0) -> void:
	_reset_movents()
	follow_actor = p_follow_actor
	follow_distance_squared = p_distance_squared
	force = p_force


func impulse(p_pos: Vector2, p_force: float) -> void:
	_reset_movents()
	direction = pos.direction_to(p_pos)
	# TODO use calc to transform force to speed
	force = p_force


func is_moving() -> bool:
	return force > 0


func stop() -> void:
	_reset_movents()
	force = 0
	last_pos = pos
	next_pos = pos


func collides(actor: MovingActor) -> bool:
	if actor == null:
		return false
	return actor.pos.distance_to(pos) < actor.collision_radius + collision_radius


func destination_reached() -> bool:
	if is_moving():
		return pos.distance_squared_to(destination) < 100
	return true


# func position_after_ticks() -> bool:


func _reset_movents() -> void:
	direction = Vector2.INF
	destination = Vector2.INF
	follow_actor = null

