# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualStateMachine
extends ScrollContainer

const MAX_STATES: int = 3

var home_team: SimTeam
var away_team: SimTeam
var home_player_states: Array[Label]
var away_player_states: Array[Label]

@onready var home_team_container: VBoxContainer = %Home
@onready var away_team_container: VBoxContainer = %Away
@onready var home_team_state: Label = %HomeTeamState
@onready var away_team_state: Label = %AwayTeamState


func _process(_delta: float) -> void:
	home_team_state.text = home_team.state_machine.state.name
	away_team_state.text = away_team.state_machine.state.name

	if home_team.state_machine.buffer.size() > 3:
		home_team_state.text += "\n" + home_team.state_machine.buffer[-2].name
		home_team_state.text += "\n" + home_team.state_machine.buffer[-3].name

	if away_team.state_machine.buffer.size() > 3:
		away_team_state.text += "\n" + away_team.state_machine.buffer[-2].name
		away_team_state.text += "\n" + away_team.state_machine.buffer[-3].name

	for i: int in 5:
		var home_player: SimPlayer = home_team.players[i]
		var home_label: Label = home_player_states[i]
		# set last x states
		home_label.text = home_player.player_res.surname + "\n"
		var max_states: int = min(MAX_STATES, home_player.state_machine.buffer.size())
		for j: int in range(max_states, 1, -1):
			home_label.text += home_player.state_machine.buffer[-j].name + "\n"
		home_label.text += home_player.state_machine.buffer[-1].name

		var away_player: SimPlayer = away_team.players[i]
		var away_label: Label = away_player_states[i]
		# set last x states
		away_label.text = away_player.player_res.surname + "\n"
		max_states = min(MAX_STATES, away_player.state_machine.buffer.size() - 1)
		for j: int in range(max_states, 1, -1):
			away_label.text += away_player.state_machine.buffer[-j].name + "\n"
		away_label.text += away_player.state_machine.buffer[-1].name


func setup(p_home_team: SimTeam, p_away_team: SimTeam) -> void:
	if not DebugUtil.visual_state_machine:
		queue_free()

	home_team = p_home_team
	away_team = p_away_team

	home_player_states = []
	away_player_states = []

	for i: int in 5:
		var home_label: Label = Label.new()
		home_player_states.append(home_label)
		home_team_container.add_child(home_label)

		var away_label: Label = Label.new()
		# away_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		away_player_states.append(away_label)
		away_team_container.add_child(away_label)
