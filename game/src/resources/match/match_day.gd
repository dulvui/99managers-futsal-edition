# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchDay
extends JSONResource

@export var day: int
@export var month: Enum.Months

@export var matches: Array[Match]


func _init(
	p_matches: Array[Match] = [],
	p_day: int = 0,
	p_month: Enum.Months = Enum.Months.JANUARY,
) -> void:
	matches = p_matches
	day = p_day
	month = p_month


func is_day(p_day: int, p_month: int) -> bool:
	if day != p_day:
		return false
	if month != p_month:
		return false
	return true


func get_matches_by_competition(competition_id: int) -> Array[Match]:
	var matches_by_competition: Array[Match] = []

	for matchz: Match in matches:
		if matchz.competition_id == competition_id:
			matches_by_competition.append(matchz)

	return matches_by_competition


#
# Array helper functions
#
func append(matchz: Match) -> void:
	matches.append(matchz)


func append_array(p_matches: Array[Match]) -> void:
	matches.append_array(p_matches)


func size() -> int:
	return matches.size()


