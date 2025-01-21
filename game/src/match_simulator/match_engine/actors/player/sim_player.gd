# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPlayer
extends MovingActor

# resources
var player_res: Player
var field: SimField
var state_machine: PlayerStateMachine

# positions
var start_pos: Vector2
# movements
var head_look_direction: Vector2

# goalkeeper properties
var is_goalkeeper: bool
var left_base: Vector2
var right_base: Vector2
var left_half: bool

var has_ball: bool


func _init(p_radius: float = 20) -> void:
	super(p_radius, false)
	# initial test values
	has_ball = false

	head_look_direction = Vector2.ZERO


func setup(
	p_player_res: Player,
	p_team: SimTeam,
	p_field: SimField,
	p_left_half: bool,
) -> void:
	player_res = p_player_res
	field = p_field
	left_half = p_left_half
	
	state_machine = PlayerStateMachine.new(field, self, p_team)
	
	# goalkeeper properties
	left_base = Vector2(field.line_left + 30, field.size.y / 2)
	right_base = Vector2(field.line_right - 30, field.size.y / 2)


func update() -> void:
	move()

	state_machine.execute()
	
	if speed > 0:
		player_res.consume_stamina(speed)


func set_state(state: PlayerStateMachineState) -> void:
	state_machine.set_state(state)


func make_goalkeeper() -> void:
	is_goalkeeper = true


func is_touching_ball() -> bool:
	return collides(field.ball)


func recover_stamina(factor: int = 1) -> void:
	player_res.recover_stamina(factor)


func move_offense_pos() -> void:
	var deviation_x: int = RngUtil.match_rng.randi_range(-10, 10)
	var deviation_y: int = RngUtil.match_rng.randi_range(-10, 10)
	var deviation: Vector2 = Vector2(field.size.x / 3 + deviation_x, deviation_y)

	if not left_half:
		deviation.x = -deviation.x

	set_destination(start_pos + deviation, 20)


func move_defense_pos() -> void:
	var deviation_x: int = RngUtil.match_rng.randi_range(-10, 10)
	var deviation_y: int = RngUtil.match_rng.randi_range(-10, 10)
	var deviation: Vector2 = Vector2(deviation_x, deviation_y)

	set_destination(start_pos + deviation)


