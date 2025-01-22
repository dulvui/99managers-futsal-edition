# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatch
extends Node2D

var engine: MatchEngine

var ball_delta: float
var states_delta: float

@onready var home_team: VisualTeam = $VisualTeamHome
@onready var away_team: VisualTeam = $VisualTeamAway
@onready var ball: VisualBall = $VisualBall
@onready var field: VisualField = $VisualField

# used for debugging and to see real ball position and not interpolations
@onready var visual_ball_real: Sprite2D = $VisualBallReal


func _physics_process(delta: float) -> void:
	visual_ball_real.position = engine.field.ball.pos
	
	ball_delta += delta
	states_delta += delta


func setup(p_engine: MatchEngine, update_interval: float) -> void:
	engine = p_engine
	field.setup(engine.field)
	ball.setup(engine.field.ball, update_interval)
	
	var home_color: Color = engine.home_team.res_team.get_home_color()
	var away_color: Color = engine.away_team.res_team.get_away_color(home_color)
	home_team.setup(engine.home_team, ball, home_color, update_interval)
	away_team.setup(engine.away_team, ball, away_color, update_interval)

	ball_delta = 0.0
	states_delta = 0.0

	engine.ball_update.connect(update_ball)
	engine.players_update.connect(update_players)


func update_ball() -> void:
	# update time intervals for position interpolations
	ball.update(ball_delta)
	ball_delta = 0.0


func update_players() -> void:
	home_team.update(states_delta)
	away_team.update(states_delta)
	states_delta = 0.0
