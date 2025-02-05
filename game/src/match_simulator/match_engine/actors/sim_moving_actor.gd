# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MovingActor

var pos: Vector2
var last_pos: Vector2
var next_pos: Vector2

var direction: Vector2
var destination: Vector2
var follow_actor: MovingActor

var collision_radius: float
var speed: float


func _init(p_collision_radius: float) -> void:
	# collision_radius = pow(p_collision_radius, 2)
	collision_radius = p_collision_radius

	_reset_movents()


func set_pos(p_pos: Vector2) -> void:
	pos = p_pos
	stop()


func set_pos_xy(x: float, y: float) -> void:
	pos.x = x
	pos.y = y
	stop()


func set_destination(p_pos: Vector2, p_speed: float = 10) -> void:
	_reset_movents()
	destination = p_pos
	speed = p_speed


func follow(p_follow_actor: MovingActor, p_speed: float = 10) -> void:
	_reset_movents()
	follow_actor = p_follow_actor
	speed = p_speed


func impulse(p_pos: Vector2, force: float) -> void:
	_reset_movents()
	direction = pos.direction_to(p_pos)
	# TODO use calc to transform force to speed
	speed = force


func is_moving() -> bool:
	return speed > 0


func stop() -> void:
	_reset_movents()
	speed = 0
	last_pos = pos
	next_pos = pos


func collides(actor: MovingActor) -> bool:
	if actor == null:
		return false
	return actor.pos.distance_to(pos) < actor.collision_radius + collision_radius


func destination_reached() -> bool:
	return pos == destination


func move() -> void:
	if speed > 0:
		last_pos = pos
		pos = next_pos
		
		# calc next pos
		if direction != Vector2.INF:
			next_pos += direction * speed * Const.SPEED
		elif destination != Vector2.INF:
			next_pos = pos.move_toward(destination, speed * Const.SPEED)
		elif follow_actor != null:
			next_pos = pos.move_toward(follow_actor.pos, speed * Const.SPEED)
	
		if speed <= 0:
			stop()


func _reset_movents() -> void:
	direction = Vector2.INF
	destination = Vector2.INF
	follow_actor = null

