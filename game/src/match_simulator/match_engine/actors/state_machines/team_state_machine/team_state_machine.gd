# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateMachine
extends StateMachine

var team: SimTeam
var team_opponents: SimTeam
# key players
var player_control: SimPlayer
var player_support: SimPlayer
var player_receive_ball: SimPlayer
var player_nearest_to_ball: SimPlayer


func _init(p_field: SimField, p_team: SimTeam, p_team_opponents: SimTeam) -> void:
	super(p_field)
	team = p_team
	team_opponents = p_team_opponents
	set_state(TeamStateEnterField.new())


func set_state(p_state: StateMachineState) -> void:
	(p_state as TeamStateMachineState).owner = self
	super(p_state)


func reset_key_players() -> void:
	player_control = null
	player_support = null
	player_receive_ball = null
	player_nearest_to_ball = null

