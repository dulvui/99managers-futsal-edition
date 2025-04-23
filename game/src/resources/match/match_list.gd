# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchList
extends Resource

var match_days: MatchDays
# history season matches, saved as csv
var history_match_days: Array[MatchDays]


func _init(
	p_match_days: MatchDays = MatchDays.new(),
	p_history_match_days: Array[MatchDays] = []
) -> void:
	match_days = p_match_days
	history_match_days = p_history_match_days


func random_results() -> void:
	var match_engine: MatchEngine = MatchEngine.new()
	var matches: Array[Match] = get_matches_by_day()
	for matchz: Match in matches:
		if not matchz.has_active_team() and not matchz.over:
			# set true for fast simulation
			match_engine.simulate_match(matchz, true)


func add_matches(matches: Array[Match], day: int, month: Enum.Months) -> void:
	for match_day: MatchDay in match_days.days:
		if match_day.is_day(day, month):
			match_day.matches.append_array(matches)
			return
	
	# no matchday with day/month found, append new
	match_days.append(MatchDay.new(matches, day, month))

	# sort match days
	match_days.days.sort_custom(
		func(a: MatchDay, b: MatchDay) -> bool:
			if a.month < b.month:
				return true
			if a.month == b.month:
				return a.day < b.day
			return false
	)


func get_matches_by_day(p_day: Day = Global.calendar.day()) -> Array[Match]:
	for match_day: MatchDay in match_days.days:
		if match_day.is_day(p_day.day, p_day.month):
			return match_day.matches
	return []


func get_match_day_by_day(p_day: Day = Global.calendar.day()) -> MatchDay:
	for match_day: MatchDay in match_days.days:
		if match_day.is_day(p_day.day, p_day.month):
			return match_day
	return null


func get_active_match(day: Day = null, also_over: bool = false) -> Match:
	if day == null:
		for match_day: MatchDay in match_days.days:
			for matchz: Match in match_day.matches:
				if not also_over and matchz.over:
					continue
				if Global.team.id in [matchz.home.id, matchz.away.id]:
					return matchz
	else:
		for matchz: Match in get_matches_by_day(day):
			if Global.team.id in [matchz.home.id, matchz.away.id]:
				if not also_over and matchz.over:
					continue
				return matchz
	return null


func get_match_days_by_competition(competition_id: int, history_index: int = -1) -> Array[MatchDay]:
	var match_days_by_competition: Array[MatchDay] = []

	for match_day: MatchDay in _get_active_match_days(history_index).days:
			if match_day.matches.any(
				func(m: Match) -> bool: return m.competition_id == competition_id
			):
				match_days_by_competition.append(match_day)
	
	return match_days_by_competition


func get_matches_by_competition(competition_id: int, history_index: int = -1) -> Array[Match]:
	var matches: Array[Match] = []

	for match_day: MatchDay in _get_active_match_days(history_index).days:
		matches.append_array(
			match_day.matches.filter(
				func(m: Match) -> bool: return m.competition_id == competition_id
			)
		)
	
	return matches


func get_match_by_id(match_id: int, history_index: int = -1) -> Match:
	for match_day: MatchDay in _get_active_match_days(history_index).days:
		for matchz: Match in match_day.matches:
			if matchz.id == match_id:
				return matchz
	push_error("match with id %d not found" % match_id)
	return null


func get_matches_by_ids(match_ids: Array[int], history_index: int = -1) -> Array[Match]:
	var matches: Array[Match] = []

	for match_day: MatchDay in _get_active_match_days(history_index).days:
		for matchz: Match in match_day.matches:
			if matchz.id in match_ids:
				matches.append(matchz)
	
	return matches


func get_history_match_by_id(match_id: int) -> Match:
	for h_match_days: MatchDays in history_match_days:
		for match_day: MatchDay in h_match_days.days:
			for matchz: Match in match_day.matches:
				if matchz.id == match_id:
					return matchz
	push_error("match with id %d not found in history" % match_id)
	return null


func is_match_day() -> bool:
	return get_active_match(Global.calendar.day()) != null


func archive_season() -> void:
	history_match_days.append(match_days)
	match_days = MatchDays.new()
	# set flag to save match history
	DataUtil.write_match_history = true


func _get_active_match_days(history_index: int) -> MatchDays:
	if history_index < 0:
		return match_days
	if history_index >= history_match_days.size():
		return match_days
	return history_match_days[history_index]

