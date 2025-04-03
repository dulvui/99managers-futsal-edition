# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchDays
extends JSONResource

# days with matches still to play
@export var days: Array[MatchDay]


func _init(
	p_days: Array[MatchDay] = [],
) -> void:
	days = p_days


func append(match_day: MatchDay) -> void:
	days.append(match_day)

