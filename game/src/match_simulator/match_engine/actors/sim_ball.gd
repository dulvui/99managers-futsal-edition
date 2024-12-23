# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimBall


enum State { PASS, SHOOT, STOP, DRIBBLE, GOALKEEPER, OUT }

const DECELERATION: float = 2

var state: State

var pos: Vector2
# to save last position and be able to get segment between ticks, for interceptions
var last_pos: Vector2

var speed: float
var direction: Vector2
# left -1, right 1, no roatation 0
var rotation: float

var players_in_shoot_trajectory: int
var empty_net: bool

var field: SimField

var clock_running: bool


func setup(p_field: SimField) -> void:
	field = p_field
	pos = field.center
	last_pos = pos
	state = State.STOP
	clock_running = false


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
	else:
		speed = 0
	
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


func is_moving() -> bool:
	return speed > 0


func stop() -> void:
	rotation = 0
	speed = 0
	last_pos = pos
	state = State.STOP


func short_pass(p_destination: Vector2, force: float) -> void:
	_random_rotation()
	speed = force + 0.2  # ball moves a bit faster that the force is
	direction = pos.direction_to(p_destination)
	state = State.PASS


func shoot(p_destination: Vector2, force: float) -> void:
	_random_rotation()
	speed = force + 4  # ball moves a bit faster that the force is
	direction = pos.direction_to(p_destination)
	state = State.SHOOT
# func shoot_on_goal(player: Player) -> void:
# 	var power: int = player.attributes.technical.shooting
#
# 	var random_target: Vector2
# 	if left_half:
# 		random_target = field.goal_right
# 	else:
# 		random_target = field.goal_left
#
# 	random_target += Vector2(
# 		0, RngUtil.match_rng.randi_range(-field.GOAL_SIZE * 1.5, field.GOAL_SIZE * 1.5)
# 	)
#
# 	field.ball.shoot(random_target, power * RngUtil.match_rng.randi_range(2, 6))
#
# 	stats.shots += 1


func dribble(p_destination: Vector2, force: float) -> void:
	speed = force
	direction = pos.direction_to(p_destination)
	state = State.DRIBBLE


func is_touching(player_pos: Vector2, player_radius: int) -> bool:
	return Geometry2D.is_point_in_circle(pos, player_pos, player_radius)


func _random_rotation() -> void:
	rotation = RngUtil.match_rng.randf_range(-0.8, 0.8)
