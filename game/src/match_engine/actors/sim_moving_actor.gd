# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MovingActor

const MIN_DISTANCE: int = 100

var pos: Vector2
var last_pos: Vector2
var next_pos: Vector2

var direction: Vector2
var destination: Vector2

var follow_actor: MovingActor
# to keep distance to following object
# use squared for performance
var follow_distance_squared: float

var collision_radius_squared: float
var force: float
var friction: float

var can_move: bool
# timer to make actor immune to collisons
# makes passing/shooting easier
var collision_timer: int


func _init(p_collision_radius_squared: float, p_friction: float) -> void:
	can_move = true
	collision_timer = 0
	# make square of radius, because colission detection uses distance_squared_to
	collision_radius_squared = pow(p_collision_radius_squared, 2)
	friction = p_friction

	_reset_movents()


func move() -> void:
	if collision_timer > 0:
		collision_timer =- 1

	if force > 0:
		last_pos = pos
		pos = next_pos

		# set destination to following actor, if set
		if follow_actor	!= null and destination != follow_actor.pos:
			destination = follow_actor.pos
			if pos.distance_squared_to(destination) <= follow_distance_squared:
				stop()
				return
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
	# min distance should be colission radius
	follow_distance_squared = p_distance_squared
	force = p_force


func impulse(p_direction: Vector2, p_force: float) -> void:
	_reset_movents()
	direction = p_direction
	force = p_force


# return ticks needed to reach destination with given force
# returns FULL_TIME_TICKS if cannot be reached in time
func get_ticks_to_reach(p_destination: Vector2, p_force: float) -> int:
	var temp_pos: Vector2 = Vector2(pos)
	var temp_direction: Vector2 = pos.direction_to(p_destination)
	var temp_force: float = p_force

	var ticks: int = 0

	var distance: float = temp_pos.distance_squared_to(p_destination)
	while distance < MIN_DISTANCE and distance > 0:
		temp_pos += temp_direction * temp_force * Const.SPEED
		ticks += 1
		temp_force -= friction

		# will never reach target
		if temp_force < 0.0:
			# simply return biiiiig number
			return Const.FULL_TIME_TICKS

		distance = temp_pos.distance_squared_to(p_destination)
	
	return ticks


func is_moving() -> bool:
	return force > 0


func stop() -> void:
	_reset_movents()
	force = 0
	last_pos = pos
	next_pos = pos


# check collision with actor, by comparing colission radius distances
# delta_squared can be used to reduce/increase colission radius
# makes check if player touches ball easier
func collides(actor: MovingActor) -> bool:
	if actor == null:
		return false

	if actor.collision_timer > 0:
		print("collision timer at work")
		return false

	# if can't collide, if actor is behind self
	# dot product of direction and directon from actor to self
	if self is SimBall and is_moving() and direction.dot(actor.pos.direction_to(pos)) > 0.0:
		return false

	var radius_sum: float = collision_radius_squared
	radius_sum += actor.collision_radius_squared
	return actor.pos.distance_squared_to(pos) <= radius_sum

func destination_reached() -> bool:
	if not is_moving():
		return true
	return pos.distance_squared_to(destination) < MIN_DISTANCE


func _reset_movents() -> void:
	direction = Vector2.INF
	destination = Vector2.INF
	follow_actor = null

