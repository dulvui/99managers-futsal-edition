# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TableValues
extends JSONResource

@export var team_id: int
@export var team_name: String
@export var points: int
@export var games_played: int
@export var goals_made: int
@export var goals_conceded: int
@export var wins: int
@export var draws: int
@export var lost: int


func _init(
	p_team_id: int = 0,
	p_team_name: String = "",
	p_points: int = 0,
	p_games_played: int = 0,
	p_goals_made: int = 0,
	p_goals_conceded: int = 0,
	p_wins: int = 0,
	p_draws: int = 0,
	p_lost: int = 0,
) -> void:
	team_id = p_team_id
	team_name = p_team_name
	points = p_points
	games_played = p_games_played
	goals_made = p_goals_made
	goals_conceded = p_goals_conceded
	wins = p_wins
	draws = p_draws
	lost = p_lost


func reset_values() -> void:
	points = 0
	games_played = 0
	goals_made = 0
	goals_conceded = 0
	wins = 0
	draws = 0
	lost = 0
