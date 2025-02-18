# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualTeam
extends Node2D

@onready var player1: VisualPlayer = $VisualPlayer1
@onready var player2: VisualPlayer = $VisualPlayer2
@onready var player3: VisualPlayer = $VisualPlayer3
@onready var player4: VisualPlayer = $VisualPlayer4
@onready var player5: VisualPlayer = $VisualPlayer5


func setup(
	player_pos: Array[Vector2],
	player_infos: Array[String],
	shirt_color: String,
	ball: VisualBall,
) -> void:
	player1.setup(player_pos[0], player_infos[0], shirt_color, ball)
	player2.setup(player_pos[1], player_infos[1], shirt_color, ball)
	player3.setup(player_pos[2], player_infos[2], shirt_color, ball)
	player4.setup(player_pos[3], player_infos[3], shirt_color, ball)
	player5.setup(player_pos[4], player_infos[4], shirt_color, ball)


func update(player_pos: Array[Vector2], player_infos: Array[String], player_head_look: Array[Vector2]) -> void:
	player1.update(player_pos[0], player_infos[0], player_head_look[0])
	player2.update(player_pos[1], player_infos[1], player_head_look[1])
	player3.update(player_pos[2], player_infos[2], player_head_look[2])
	player4.update(player_pos[3], player_infos[3], player_head_look[3])
	player5.update(player_pos[4], player_infos[4], player_head_look[4])


