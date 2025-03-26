# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchList
extends JSONResource

@export var match_days: MatchDays
# old season matches
@export var history_match_days: Array[MatchDays]


func _init(
	p_match_days: MatchDays = MatchDays.new(),
	p_history_match_days: Array[MatchDays] = []
) -> void:
	match_days = p_match_days
	history_match_days = p_history_match_days


func add_matches(matches: Array[Match], day: int, month: Enum.Months) -> void:
	for match_day: MatchDay in match_days.days:
		if match_day.is_day(day, month):
			match_day.matches.append_array(matches)
			return
	
	# no matchday with day/month found, append new
	match_days.append(MatchDay.new(matches, day, month))


func get_matches_by_day(p_day: Day = Global.world.calendar.day()) -> Array[Match]:
	for match_day: MatchDay in match_days.days:
		if match_day.is_day(p_day.day, p_day.month):
			return match_day.matches
	return []


func get_match_day_by_day(p_day: Day = Global.world.calendar.day()) -> MatchDay:
	for match_day: MatchDay in match_days.days:
		if match_day.is_day(p_day.day, p_day.month):
			return match_day
	return null


func get_active_match(day: Day = null) -> Match:
	if day == null:
		for match_day: MatchDay in match_days.days:
			for matchz: Match in match_day.matches:
				if Global.team.id in [matchz.home.id, matchz.away.id]:
					return matchz
	else:
		for matchz: Match in get_matches_by_day(day):
			if Global.team.id in [matchz.home.id, matchz.away.id]:
				return matchz
	return null


func get_match_days_by_competition(competition_id: int) -> Array[MatchDay]:
	var match_days_by_competition: Array[MatchDay] = []

	for match_day: MatchDay in match_days.days:
			if match_day.matches.any(
				func(m: Match) -> bool: return m.competition_id == competition_id
			):
				match_days_by_competition.append(match_day)
	
	return match_days_by_competition


func get_matches_by_competition(competition_id: int) -> Array[Match]:
	var matches: Array[Match] = []

	for match_day: MatchDay in match_days.days:
		matches.append_array(
			match_day.matches.filter(
				func(m: Match) -> bool: return m.competition_id == competition_id
			)
		)
	
	return matches


func is_match_day() -> bool:
	return get_active_match(Global.world.calendar.day()) != null


func archive_days() -> void:
	var finished_match_days: Array[MatchDay] = []

	for match_day: MatchDay in match_days.days:
		if match_day.matches.any(func(m: Match) -> bool: return m.over):
			finished_match_days.append(match_day)
	
	for match_day: MatchDay in finished_match_days:
		match_days.days.erase(match_day)
	
	match_days.history_days.append_array(finished_match_days)


func archive_season() -> void:
	history_match_days.append(match_days)
	match_days = MatchDays.new()

