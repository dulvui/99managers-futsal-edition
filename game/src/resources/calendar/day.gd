# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Day
extends JSONResource

@export var matches: Array[Match]
@export var market: bool
@export var weekday: Enum.Weekdays
@export var day: int
@export var month: Enum.Months
@export var year: int
#@export var trainings: Array


func _init(
	p_matches: Array[Match] = [],
	p_market: bool = false,
	p_weekday: Enum.Weekdays = Enum.Weekdays.THURSDAY,
	p_day: int = 1,
	p_month: Enum.Months = Enum.Months.JANUARY,
	p_year: int = 1970,
) -> void:
	matches = p_matches
	market = p_market
	weekday = p_weekday
	day = p_day
	month = p_month
	year = p_year


func add_matches(p_matches: Array) -> void:
	matches.append_array(p_matches)


func get_active_match() -> Match:
	for matchz: Match in matches:
		if Global.team.id in [matchz.home.id, matchz.away.id]:
			return matchz
	return null


func get_matches(competition_id: int = -1) -> Array:
	# return all matches on this day
	if competition_id == -1:
		return matches
	# only return competition specific matches on this day
	return matches.filter(func(m: Match) -> bool: return m.competition_id == competition_id)


func to_format_string() -> String:
	return (
		Enum.get_weekday_text(weekday)
		+ " "
		+ str(day)
		+ " "
		+ Enum.get_month_text(month - 1)
		+ " "
		+ str(year)
	)


func is_same_day(p_day: Day) -> bool:
	if day != p_day.day:
		return false
	if month != p_day.month:
		return false
	if year != p_day.year:
		return false
	return true
