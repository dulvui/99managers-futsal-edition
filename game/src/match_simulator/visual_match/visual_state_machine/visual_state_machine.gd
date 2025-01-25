# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualStateMachine
extends Control


var home_team: VisualTeam
var away_team: VisualTeam
var home_player_states: Array[Label] 
var away_player_states: Array[Label] 

@onready var home_team_state: Label = %HomeTeamState
@onready var away_team_state: Label = %AwayTeamState


func _process(_delta: float) -> void:
	home_team_state.text = home_team.team.state_machine.state.name
	away_team_state.text = away_team.team.state_machine.state.name

	for i: int in 5:
		var home_player: VisualPlayer = home_team.get("player" + str(i + 1))
		var home_label: Label = home_player_states[i]
		# set last x states
		home_label.text = ""
		var max_states: int = min(7, home_player.sim_player.state_machine.buffer.size())
		for j: int in range(max_states, 1, -1):
			home_label.text += home_player.sim_player.state_machine.buffer[-j].name + "\n"
		home_label.text += home_player.sim_player.state_machine.buffer[-1].name
		home_label.global_position = home_player.global_position - Vector2(0, 50)
		
		var away_player: VisualPlayer = away_team.get("player" + str(i + 1))
		var away_label: Label = away_player_states[i]
		away_label.global_position = away_player.global_position
		# set last x states
		away_label.text = ""
		max_states = min(7, away_player.sim_player.state_machine.buffer.size() - 1)
		for j: int in range(max_states, 1, -1):
			away_label.text += away_player.sim_player.state_machine.buffer[-j].name + "\n"
		away_label.text += away_player.sim_player.state_machine.buffer[-1].name


func setup(p_home_team: VisualTeam, p_away_team: VisualTeam) -> void:

	if not DebugUtil.visual_state_machine:
		queue_free()

	home_team = p_home_team
	away_team = p_away_team

	home_player_states = []
	away_player_states = []

	for i: int in 5:
		var home_label: Label = Label.new()
		home_player_states.append(home_label)
		add_child(home_label)
		home_label.set("theme_override_font_sizes/font_size", 12)

		var away_label: Label = Label.new()
		away_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		away_player_states.append(away_label)
		add_child(away_label)
		away_label.set("theme_override_font_sizes/font_size", 12)
