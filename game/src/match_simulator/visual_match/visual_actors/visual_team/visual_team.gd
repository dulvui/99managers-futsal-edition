# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualTeam
extends Node2D


@onready var player1: VisualPlayer = $VisualPlayer1
@onready var player2: VisualPlayer = $VisualPlayer2
@onready var player3: VisualPlayer = $VisualPlayer3
@onready var player4: VisualPlayer = $VisualPlayer4
@onready var player5: VisualPlayer = $VisualPlayer5


func set_up(
	sim_team: SimTeam, visual_ball: VisualBall, shirt_color: Color, update_interval: float
) -> void:
	player1.set_up(sim_team.players[0], visual_ball, shirt_color.lightened(0.4), update_interval)
	player2.set_up(sim_team.players[1], visual_ball, shirt_color, update_interval)
	player3.set_up(sim_team.players[2], visual_ball, shirt_color, update_interval)
	player4.set_up(sim_team.players[3], visual_ball, shirt_color, update_interval)
	player5.set_up(sim_team.players[4], visual_ball, shirt_color, update_interval)


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

