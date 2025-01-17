# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall
extends MovingActor


enum State { PASS, SHOOT, STOP, DRIBBLE, GOALKEEPER, OUT }

const DECELERATION: float = 2

var state: State

# left -1, right 1, no roatation 0
var rotation: float

var field: SimField

func setup(p_field: SimField) -> void:
	field = p_field
	pos = field.center
	last_pos = pos
	state = State.STOP
	rotation = 0


func set_pos(p_pos: Vector2) -> void:
	pos = p_pos
	stop()


func set_pos_xy(x: float, y: float) -> void:
	pos.x = x
	pos.y = y
	stop()


func update() -> void:
	if speed > 0:
		move()
		field.clock_running = true
	else:
		speed = 0
	
	if rotation != 0:
		if rotation > 0.1:
			rotation -= 0.05
		elif rotation < 0.1:
			rotation += 0.05
		else:
			rotation = 0
	
	# print("ball state %s"%State.keys()[state])


func move() -> void:
	last_pos = pos
	pos += direction * speed * Const.SPEED
	speed -= DECELERATION


func short_pass(p_destination: Vector2, force: float) -> void:
	_random_rotation()
	speed = force
	direction = pos.direction_to(p_destination)
	state = State.PASS


func shoot(p_destination: Vector2, force: float) -> void:
	_random_rotation()
	speed = force + 4  # ball moves a bit faster that the force is
	direction = pos.direction_to(p_destination)
	state = State.SHOOT


func shoot_on_goal(player: Player, left_half: bool) -> void:
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


func dribble(p_destination: Vector2, force: float) -> void:
	speed = force
	direction = pos.direction_to(p_destination)
	state = State.DRIBBLE


func _random_rotation() -> void:
	rotation = RngUtil.match_rng.randf_range(-0.8, 0.8)