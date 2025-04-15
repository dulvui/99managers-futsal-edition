# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatch
extends Node2D

@onready var home_team: VisualTeam = $VisualTeamHome
@onready var away_team: VisualTeam = $VisualTeamAway
@onready var ball: VisualBall = $VisualBall
@onready var field: VisualField = $VisualField
@onready var goals: VisualGoals = $VisualGoals


func setup(simulator: MatchSimulator) -> void:
	field.setup(simulator.engine.field)
	goals.setup(simulator.engine.field)
	ball.setup(simulator.engine.field.ball.pos)

	var home_color: String = simulator.engine.home_team.team_res.get_home_color()
	var away_color: String = simulator.engine.away_team.team_res.get_away_color(home_color)

	var home_pos: Array[Vector2] = []
	var home_info: Array[String] = []
	var home_skintones: Array[String] = []
	var home_hair_colors: Array[String] = []
	var home_eye_colors: Array[String] = []
	for player: SimPlayer in simulator.engine.home_team.players:
		home_pos.append(player.pos)
		home_info.append(str(player.player_res.nr) + " " + player.player_res.surname)
		home_skintones.append(player.player_res.skintone)
		home_hair_colors.append(player.player_res.haircolor)
		home_eye_colors.append(player.player_res.eyecolor)
	home_team.setup(
		home_pos, home_info, home_skintones, home_hair_colors, home_eye_colors, home_color, ball
	)

	var away_pos: Array[Vector2] = []
	var away_info: Array[String] = []
	var away_skintones: Array[String] = []
	var away_hair_colors: Array[String] = []
	var away_eye_colors: Array[String] = []
	for player: SimPlayer in simulator.engine.away_team.players:
		away_pos.append(player.pos)
		away_info.append(str(player.player_res.nr) + " " + player.player_res.surname)
		away_skintones.append(player.player_res.skintone)
		away_hair_colors.append(player.player_res.haircolor)
		away_eye_colors.append(player.player_res.eyecolor)
	away_team.setup(
		away_pos, away_info, away_skintones, away_hair_colors, away_eye_colors, away_color, ball
	)


func hide_actors() -> void:
	ball.hide()
	home_team.hide()
	away_team.hide()


func show_actors() -> void:
	ball.show()
	home_team.show()
	away_team.show()

