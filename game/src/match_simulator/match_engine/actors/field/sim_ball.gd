# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall
extends MovingActor


enum State { PASS, SHOOT, STOP, DRIBBLE, GOALKEEPER, OUT }


var state: State

# left -1, right 1, no roatation 0
var rotation: float

var field: SimField


func _init() -> void:
	super(8, true)


func setup(p_field: SimField) -> void:
	field = p_field
	pos = field.center
	rotation = 0


func update() -> void:
	move()

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
	
	
	# print("ball state %s"%State.keys()[state])


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
		0, RngUtil.match_rng.randi_range(-field.goals.size * 1.5, field.goals.size * 1.5)
	)

	shoot(random_target, power * RngUtil.match_rng.randi_range(2, 6))


func _random_rotation() -> void:
	rotation = RngUtil.match_rng.randf_range(-0.8, 0.8)
