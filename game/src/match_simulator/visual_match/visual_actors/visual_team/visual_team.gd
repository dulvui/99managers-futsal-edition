# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualTeam
extends Node2D

@onready var player1: VisualPlayer = $VisualPlayer1
@onready var player2: VisualPlayer = $VisualPlayer2
@onready var player3: VisualPlayer = $VisualPlayer3
@onready var player4: VisualPlayer = $VisualPlayer4
@onready var player5: VisualPlayer = $VisualPlayer5


# func setup(player_pos: Array[Vector2], player_infos: Array[String], shirt_color: Color) -> void:
# 	player1.setup(player_pos[0], player_infos[0], shirt_color.lightened(0.4))
# 	player2.setup(player_pos[1], player_infos[1], shirt_color)
# 	player3.setup(player_pos[2], player_infos[2], shirt_color)
# 	player4.setup(player_pos[3], player_infos[3], shirt_color)
# 	player5.setup(player_pos[4], player_infos[4], shirt_color)
#
#
# func update(player_pos: Array[Vector2], update_interval: float, player_infos: Array[String]) -> void:
# 	player1.update(player_pos[0], update_interval, player_infos[0])
# 	player2.update(player_pos[1], update_interval, player_infos[1])
# 	player3.update(player_pos[2], update_interval, player_infos[2])
# 	player4.update(player_pos[3], update_interval, player_infos[3])
# 	player5.update(player_pos[4], update_interval, player_infos[4])
#

