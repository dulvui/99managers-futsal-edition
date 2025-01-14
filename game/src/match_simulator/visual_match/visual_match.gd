# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatch
extends Node2D

var match_engine: MatchEngine

@onready var home_team: VisualTeam = $VisualTeamHome
@onready var away_team: VisualTeam = $VisualTeamAway
@onready var visual_ball: VisualBall = $VisualBall
@onready var visual_field: VisualField = $VisualField

# used for debugging and to see real ball position and not interpolations
@onready var visual_ball_real: Sprite2D = $VisualBallReal


func _physics_process(_delta: float) -> void:
	visual_ball_real.position = match_engine.field.ball.pos


func setup(p_match_engine: MatchEngine, update_interval: float) -> void:
	match_engine = p_match_engine
	visual_field.setup(match_engine.field)
	visual_ball.setup(match_engine.field.ball, update_interval)
	
	var home_color: Color = match_engine.home_team.res_team.get_home_color()
	var away_color: Color = match_engine.away_team.res_team.get_away_color(home_color)
	home_team.setup(match_engine.home_team, visual_ball, home_color, update_interval)
	away_team.setup(match_engine.away_team, visual_ball, away_color, update_interval)


func update(update_interval: float) -> void:
	# update time intervals for position interpolations
	visual_ball.update(update_interval)
	home_team.update(update_interval)
	away_team.update(update_interval)
