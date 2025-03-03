# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name KnockoutRound
extends JSONResource

@export var matches: Array[Match]

func _init(p_matches: Array[Match] = []) -> void:
	matches = p_matches

