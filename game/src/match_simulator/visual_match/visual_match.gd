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
	home_team.setup(engine.home_team, home_color)
	away_team.setup(engine.away_team, away_color)


func update_ball(pos: Vector2) -> void:
	# update time intervals for position interpolations
	ball.update(pos)


func update_players(player_pos: Array[Vector2], update_interval: float, player_infos: Array[String]) -> void:
	home_team.update(player_pos, update_interval, player_infos)
	away_team.update(player_pos, update_interval, player_infos)


func hide_actors() -> void:
	ball.hide()
	home_team.hide()
	away_team.hide()


func show_actors() -> void:
	ball.show()
	home_team.show()
	away_team.show()


