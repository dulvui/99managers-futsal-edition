# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualTeam
extends Node2D

var team: SimTeam

@onready var player1: VisualPlayer = $VisualPlayer1
@onready var player2: VisualPlayer = $VisualPlayer2
@onready var player3: VisualPlayer = $VisualPlayer3
@onready var player4: VisualPlayer = $VisualPlayer4
@onready var player5: VisualPlayer = $VisualPlayer5


func setup(
	p_team: SimTeam, visual_ball: VisualBall, shirt_color: Color, update_interval: float
) -> void:
	team = p_team
	player1.setup(p_team.players[0], update_interval, visual_ball, shirt_color.lightened(0.4))
	player2.setup(p_team.players[1], update_interval, visual_ball, shirt_color)
	player3.setup(p_team.players[2], update_interval, visual_ball, shirt_color)
	player4.setup(p_team.players[3], update_interval, visual_ball, shirt_color)
	player5.setup(p_team.players[4], update_interval, visual_ball, shirt_color)


func update(update_interval: float) -> void:
	player1.update(update_interval)
	player2.update(update_interval)
	player3.update(update_interval)
	player4.update(update_interval)
	player5.update(update_interval)


func change_players(sim_team: SimTeam) -> void:
	player1.change_player(sim_team.players[0])
	player2.change_player(sim_team.players[1])
	player3.change_player(sim_team.players[2])
	player4.change_player(sim_team.players[3])
	player5.change_player(sim_team.players[4])

