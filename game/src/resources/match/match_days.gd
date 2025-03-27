# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchDays
extends JSONResource

# days with matches still to play
@export var days: Array[MatchDay]
# days with finished matches
@export var history_days: Array[MatchDay]


func _init(
	p_days: Array[MatchDay] = [],
	p_history_days: Array[MatchDay] = [],
) -> void:
	days = p_days
	history_days = p_history_days


func append(match_day: MatchDay) -> void:
	days.append(match_day)

