# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimFieldSector


var position: Vector2
var score: float


func setup(x: int, y: int) -> void:
	position = Vector2(x, y)
	score = 0


