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
	pos: Array[Vector2],
	infos: Array[String],
	skintones: Array[String],
	hair_color: Array[String],
	eye_color: Array[String],
	shirt_color: String,
	ball: VisualBall,
) -> void:
	player1.setup(pos[0], infos[0], skintones[0], hair_color[0], eye_color[0], shirt_color, ball)
	player2.setup(pos[1], infos[1], skintones[1], hair_color[1], eye_color[1], shirt_color, ball)
	player3.setup(pos[2], infos[2], skintones[2], hair_color[2], eye_color[2], shirt_color, ball)
	player4.setup(pos[3], infos[3], skintones[3], hair_color[3], eye_color[3], shirt_color, ball)
	player5.setup(pos[4], infos[4], skintones[4], hair_color[4], eye_color[4], shirt_color, ball)


func update(
	pos: Array[Vector2],
	head: Array[Vector2],
	infos: Array[String],
	skintones: Array[String],
	hair_color: Array[String],
	eye_color: Array[String],
) -> void:
	player1.update(pos[0], head[0],infos[0], skintones[0], hair_color[0], eye_color[0])
	player2.update(pos[1], head[1],infos[1], skintones[1], hair_color[1], eye_color[1])
	player3.update(pos[2], head[2],infos[2], skintones[2], hair_color[2], eye_color[2])
	player4.update(pos[3], head[3],infos[3], skintones[3], hair_color[3], eye_color[3])
	player5.update(pos[4], head[4],infos[4], skintones[4], hair_color[4], eye_color[4])

