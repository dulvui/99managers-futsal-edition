# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatch
extends Node2D


@onready var home_team: VisualTeam = $VisualTeamHome
@onready var away_team: VisualTeam = $VisualTeamAway
@onready var ball: VisualBall = $VisualBall
@onready var field: VisualField = $VisualField


func setup(simulator: MatchSimulator) -> void:
	field.setup(simulator.engine.field)
	ball.setup(simulator.engine.field.ball.pos)

	var home_color: Color = simulator.engine.home_team.team_res.get_home_color()
	var away_color: Color = simulator.engine.away_team.team_res.get_away_color(home_color)

	var home_team_pos: Array[Vector2] = []
	var home_team_info: Array[String] = []
	for player: SimPlayer in simulator.engine.home_team.players:
		home_team_pos.append(player.pos)
		home_team_info.append(str(player.player_res.nr) + " " + player.player_res.surname)
	home_team.setup(home_team_pos, home_team_info, home_color, ball)

	var away_team_pos: Array[Vector2] = []
	var away_team_info: Array[String] = []
	for player: SimPlayer in simulator.engine.away_team.players:
		away_team_pos.append(player.pos)
		away_team_info.append(str(player.player_res.nr) + " " + player.player_res.surname)
	away_team.setup(away_team_pos, away_team_info, away_color, ball)


func hide_actors() -> void:
	ball.hide()
	home_team.hide()
	away_team.hide()


func show_actors() -> void:
	ball.show()
	home_team.show()
	away_team.show()


