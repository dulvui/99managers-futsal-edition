# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatch
extends Node2D

var colors: StadiumColorsList

@onready var home_team: VisualTeam = $VisualTeamHome
@onready var away_team: VisualTeam = $VisualTeamAway
@onready var ball: VisualBall = $VisualBall
@onready var field: VisualField = $VisualField
@onready var goals: VisualGoals = $VisualGoals


func _ready() -> void:
	colors = StadiumColorsList.new()


func setup(simulator: MatchSimulator) -> void:
	var home: SimTeam = simulator.engine.home_team
	var away: SimTeam = simulator.engine.away_team

	ball.setup(simulator.engine.field.ball.pos)

	# set stadium colors to home team
	var stadium_color: StadiumColors = colors.list[home.res.stadium.colors_index]

	# force own stadium colors, if set
	if Global.save_states.active and Global.save_states.active.stadium_force_color:
		if Global.team and Global.team.stadium:
			stadium_color = colors.list[Global.team.stadium.colors_index]

	field.set_colors(stadium_color)
	goals.set_colors(stadium_color)

	# setup teams
	var home_color: String = home.res.get_home_color()
	var away_color: String = away.res.get_away_color(home_color)

	var home_pos: Array[Vector2] = []
	var home_info: Array[String] = []
	var home_skintones: Array[String] = []
	var home_hair_colors: Array[String] = []
	var home_eye_colors: Array[String] = []
	for player: SimPlayer in home.players:
		home_pos.append(player.pos)
		home_info.append(str(player.res.nr) + " " + player.res.surname)
		home_skintones.append(player.res.skintone)
		home_hair_colors.append(player.res.haircolor)
		home_eye_colors.append(player.res.eyecolor)
	home_team.setup(
		home_pos, home_info, home_skintones, home_hair_colors, home_eye_colors, home_color, ball
	)

	var away_pos: Array[Vector2] = []
	var away_info: Array[String] = []
	var away_skintones: Array[String] = []
	var away_hair_colors: Array[String] = []
	var away_eye_colors: Array[String] = []
	for player: SimPlayer in away.players:
		away_pos.append(player.pos)
		away_info.append(str(player.res.nr) + " " + player.res.surname)
		away_skintones.append(player.res.skintone)
		away_hair_colors.append(player.res.haircolor)
		away_eye_colors.append(player.res.eyecolor)
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

