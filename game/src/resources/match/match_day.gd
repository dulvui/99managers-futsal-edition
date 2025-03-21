# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchDay
extends JSONResource

@export var matches: Array[Match]


func _init(
	p_matches: Array[Match] = [],
) -> void:
	matches = p_matches


func append(matchz: Match) -> void:
	matches.append(matchz)


func append_array(p_matches: Array[Match]) -> void:
	matches.append_array(p_matches)


func size() -> int:
	return matches.size()
