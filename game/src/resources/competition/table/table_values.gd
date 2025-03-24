# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TableValues
extends JSONResource

enum Form {
	LOST,
	DRAW,
	WIN,
}

@export var team: TeamBasic
@export var points: int
@export var games_played: int
@export var goals_made: int
@export var goals_conceded: int
@export var wins: int
@export var draws: int
@export var lost: int
@export var form: Array[Form]


func _init(
	p_team: TeamBasic = TeamBasic.new(),
	p_points: int = 0,
	p_games_played: int = 0,
	p_goals_made: int = 0,
	p_goals_conceded: int = 0,
	p_wins: int = 0,
	p_draws: int = 0,
	p_lost: int = 0,
	p_form: Array[Form] = [],
) -> void:
	team = p_team
	points = p_points
	games_played = p_games_played
	goals_made = p_goals_made
	goals_conceded = p_goals_conceded
	wins = p_wins
	draws = p_draws
	lost = p_lost
	form = p_form


func setup(
	goals: int,
	opponent_goals: int,
	penalties_goals: int = 0,
	opponent_penalties_goals: int = 0,
	) -> void:

	games_played += 1
	goals_made += goals
	goals_conceded += opponent_goals

	var goals_sum: int = goals + penalties_goals
	var opponent_goals_sum: int = opponent_goals + opponent_penalties_goals

	if goals_sum > opponent_goals_sum:
		wins += 1
		points += 3
		form.append(Form.WIN)
	elif goals_sum == opponent_goals_sum:
		draws += 1
		points += 1
		form.append(Form.DRAW)
	else:
		lost += 1
		form.append(Form.LOST)
