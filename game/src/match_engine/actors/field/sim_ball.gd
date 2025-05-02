# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall
extends MovingActor

# ball players collision timer
# 1 so that ball doesn't collide after just started moving
const PLAYER_COLISSION_TIME: int = 2

# left -1, right 1, no roatation 0
var rotation: float
var colission_timer: int

var field: SimField

var rng: RngUtil


func _init(p_rng: RngUtil) -> void:
	super(2, 0.05)
	rng = p_rng


func setup(p_field: SimField) -> void:
	field = p_field
	pos = field.center
	rotation = 0
	# start with timer to prevent colission at kickoff
	colission_timer = PLAYER_COLISSION_TIME


func update() -> void:
	move()

	# rotation
	if is_moving():
		if abs(rotation) > 0.1:
			if rotation > 0.1:
				rotation -= 0.05
			elif rotation < 0.1:
				rotation += 0.05
			else:
				rotation = 0
	else:
		rotation = 0


func impulse(p_direction: Vector2, p_force: float) -> void:
	super(p_direction, p_force)
	# print("pass")
	_random_rotation()


func stop() -> void:
	super()
	colission_timer = PLAYER_COLISSION_TIME


func _random_rotation() -> void:
	rotation = rng.randf_range(-0.8, 0.8)

