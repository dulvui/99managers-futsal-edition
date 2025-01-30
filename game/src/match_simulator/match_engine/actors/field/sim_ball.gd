# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall
extends MovingActor


const DECELERATION: float = 0.05

enum State { PASS, SHOOT, STOP, DRIBBLE, GOALKEEPER, OUT }

# ball players collision timer
# 1 so that ball doesn't collide after just started moving
const PLAYER_COLISSION_TIME: int = 2

var state: State

# left -1, right 1, no roatation 0
var rotation: float
var colission_timer: int

var field: SimField

var rng: RandomNumberGenerator


func _init(p_rng: RandomNumberGenerator) -> void:
	super(2)
	rng = p_rng


func setup(p_field: SimField) -> void:
	field = p_field
	pos = field.center
	rotation = 0
	# start with timer to prevent colission at kickoff
	colission_timer = PLAYER_COLISSION_TIME


func update() -> void:
	move()

	if speed > 0:
		speed -= DECELERATION

	# rotation
	if speed > 0:
		if abs(rotation) > 0.1:
			if rotation > 0.1:
				rotation -= 0.05
			elif rotation < 0.1:
				rotation += 0.05
			else:
				rotation = 0
	else:
		rotation = 0


func short_pass(p_destination: Vector2, force: float) -> void:
	# print("pass")
	_random_rotation()
	impulse(p_destination, force)
	state = State.PASS


func shoot(p_destination: Vector2, force: float) -> void:
	# print("shoot")
	_random_rotation()
	impulse(p_destination, force)
	state = State.SHOOT


func dribble(p_destination: Vector2, force: float) -> void:
	# print("dribble")
	_random_rotation()
	impulse(p_destination, force)
	state = State.SHOOT


func shoot_on_goal(player: Player, left_half: bool) -> void:
	# print("shoot on goal")
	var power: int = player.attributes.technical.shooting

	var random_target: Vector2
	if left_half:
		random_target = field.goals.right
	else:
		random_target = field.goals.left

	random_target += Vector2(
		0, rng.randi_range(-field.goals.size * 1.5, field.goals.size * 1.5)
	)

	shoot(random_target, power * rng.randi_range(2, 6))


func stop() -> void:
	super()
	colission_timer = PLAYER_COLISSION_TIME


func _random_rotation() -> void:
	rotation = rng.randf_range(-0.8, 0.8)
