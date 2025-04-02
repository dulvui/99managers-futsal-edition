# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name KnockoutRound
extends JSONResource

@export var match_ids: Array[int]

func _init(p_match_ids: Array[int] = []) -> void:
	match_ids = p_match_ids

