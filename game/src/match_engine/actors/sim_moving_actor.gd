# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MovingActor

var pos: Vector2
var last_pos: Vector2
var next_pos: Vector2

var direction: Vector2
var destination: Vector2

var collision_radius: float
var collision_radius_squared: float
var force: float
var friction: float

var can_move: bool
# timer to make actor immune to collisons
# makes passing/shooting easier
var collision_timer: int


func _init(p_collision_radius: float, p_friction: float) -> void:
	can_move = true
	collision_timer = 0
	collision_radius = p_collision_radius
	# make square of radius, because colission detection uses distance_squared_to
	collision_radius_squared = pow(p_collision_radius, 2)
	friction = p_friction

	_reset_movents()


func move() -> void:
	if collision_timer > 0:
		collision_timer = collision_timer - 1

	if force > 0:
		last_pos = pos
		pos = next_pos

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


func set_destination(p_pos: Vector2, p_force: float = 10, p_overrun: float = 0.0) -> void:
	_reset_movents()
	force = p_force
	destination = p_pos
	direction = pos.direction_to(destination)

	if p_overrun > 0.0:
		destination += direction * p_overrun


func impulse(p_direction: Vector2, p_force: float) -> void:
	_reset_movents()
	direction = p_direction
	force = p_force


func is_moving() -> bool:
	return force > 0.0


func stop() -> void:
	_reset_movents()
	force = 0.0
	last_pos = pos
	next_pos = pos


# check collision with other actor
# by comparing colission radius distances
func collides(actor: MovingActor) -> bool:
	if actor == null:
		return false

	var radius_sum: float = collision_radius_squared
	radius_sum += actor.collision_radius_squared
	return actor.pos.distance_squared_to(pos) <= radius_sum


func destination_reached() -> bool:
	if not is_moving():
		return true

	# use 10px squared as min distance
	return pos.distance_squared_to(destination) < 100


func _reset_movents() -> void:
	direction = Vector2.INF
	destination = Vector2.INF

