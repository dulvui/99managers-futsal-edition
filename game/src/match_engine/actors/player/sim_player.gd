# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPlayer
extends MovingActor

# resources
var res: Player
var field: SimField
var state_machine: PlayerStateMachine

# positions
var start_pos: Vector2
# movements
var head_look: Vector2
var deviation: Vector2

# goalkeeper properties
var is_goalkeeper: bool
var left_base: Vector2
var right_base: Vector2
var left_half: bool

var has_ball: bool

# save time player is in field, to prevent changing player just entered
# only injury or manual change can change player with low time in field
var ticks_in_field: int


func _init(p_radius: float = 18) -> void:
	super(p_radius, 0.0)
	has_ball = false
	head_look = Vector2.ZERO
	is_goalkeeper = false
	ticks_in_field = 0


func setup(
	p_res: Player,
	p_team: SimTeam,
	p_field: SimField,
	p_left_half: bool,
) -> void:
	res = p_res
	field = p_field
	left_half = p_left_half

	state_machine = PlayerStateMachine.new(field, self, p_team)

	# goalkeeper properties
	left_base = Vector2(field.line_left + 30, field.size.y / 2)
	right_base = Vector2(field.line_right - 30, field.size.y / 2)


func update() -> void:
	ticks_in_field += 1

	state_machine.execute()

	if is_moving():
		res.consume_stamina(force)


func change_res(p_res: Player) -> void:
	res = p_res
	ticks_in_field = 0


func set_state(state: PlayerStateMachineState) -> void:
	state_machine.set_state(state)


func make_goalkeeper() -> void:
	is_goalkeeper = true


func is_touching_ball() -> bool:
	return collides(field.ball)


func gain_control() -> void:
	stop()

	state_machine.team.gain_possession()
	state_machine.team.player_control(self)

	# set goalkeeper ball, but only if team doesn't control ball
	if is_goalkeeper and not state_machine.team.has_ball:
		state_machine.team.set_state(TeamStateGoalkeeper.new())
		state_machine.team.team_opponents.set_state(TeamStateGoalkeeper.new())
	else:
		state_machine.team.set_state(TeamStateAttack.new())
		state_machine.team.team_opponents.set_state(TeamStateDefend.new())


func move_offense_pos() -> void:
	var offense_pos: Vector2 = Vector2(field.size.x / 3, 0)

	if not left_half:
		offense_pos.x = -offense_pos.x

	set_destination(start_pos + offense_pos)


func move_defense_pos() -> void:
	set_destination(start_pos)


func look_towards_destination() -> void:
	if destination != null:
		head_look = destination

