# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatch
extends Node2D

var ball_delta: float
var states_delta: float

@onready var home_team: VisualTeam = $VisualTeamHome
@onready var away_team: VisualTeam = $VisualTeamAway
@onready var ball: VisualBall = $VisualBall
@onready var field: VisualField = $VisualField


func _physics_process(delta: float) -> void:
	ball_delta += delta
	states_delta += delta


func setup(engine: MatchEngine, update_interval: float) -> void:
	field.setup(engine.field)
	ball.setup(engine.field.ball, update_interval)
	
	var home_color: Color = engine.home_team.team_res.get_home_color()
	var away_color: Color = engine.away_team.team_res.get_away_color(home_color)
	home_team.setup(engine.home_team, ball, home_color, update_interval)
	away_team.setup(engine.away_team, ball, away_color, update_interval)

	ball_delta = 0.0
	states_delta = 0.0


func update_ball() -> void:
	# update time intervals for position interpolations
	ball.update(ball_delta)
	ball_delta = 0.0


func update_players() -> void:
	home_team.update(states_delta)
	away_team.update(states_delta)
	states_delta = 0.0
