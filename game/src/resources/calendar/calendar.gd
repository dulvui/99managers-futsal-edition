# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Calendar
extends JSONResource

const DAY_IN_SECONDS: int = 86400

# TODO replace with different dates per nation/contintent
# season end 30th of november
const SEASON_END_DAY: int = 30
const SEASON_END_MONTH: int = 11

# market dates
const MARKET_PERIODS: Array = [
	{
		"period": "winter",
		"start":
		{
			"month": 1,
			"day": 1,
		},
		"end":
		{
			"month": 1,
			"day": 31,
		},
	},
	{
		"period": "summer",
		"start":
		{
			"month": 6,
			"day": 1,
		},
		"end":
		{
			"month": 8,
			"day": 31,
		},
	},
]

@export var date: Dictionary
@export var months: Array[Month]


func _init(
	p_date: Dictionary = {},
	p_months: Array[Month] = [],
) -> void:
	date = p_date
	months = p_months


func initialize(next_season: bool = false) -> void:
	if next_season:
		date.year += 1
		date = _get_next_day(date)
	else:
		if Global.start_date != null and Global.start_date.is_empty():
			print("calendar: Global.start_date not set, using system time dict")
			date = Time.get_date_dict_from_system()
		else:
			date = Global.start_date

	# set start date
	date.day = Const.SEASON_START_DAY
	date.month = Const.SEASON_START_MONTH

	# add 1 year at start to have total 2 years
	if not next_season:
		_add_year(date.year)

	# next season, only 1 year gets appended
	_add_year(date.year + 1)


func from_json(dict: Dictionary) -> void:
	super(dict)

	if dict.has("months"):
		for month_dict: Dictionary in dict["months"]:
			var month_new: Month = Month.new()
			month_new.from_json(month_dict)
			months.append(month_new)


func next_day() -> void:
	date = _get_next_day()


func day(p_month: int = date.month, p_day: int = date.day) -> Day:
	return months[p_month - 1].days[p_day - 1]


func month(p_month: int = date.month) -> Month:
	return months[p_month - 1]


func is_match_day() -> bool:
	var next_match: Match = get_next_match()
	return next_match != null and not next_match.over


func is_market_active(p_date: Dictionary = date) -> bool:
	for market_period: Dictionary in MARKET_PERIODS:
		if (
			p_date.month >= market_period.start.month
			and p_date.day >= market_period.start.day
			and p_date.month <= market_period.end.month
			and p_date.day <= market_period.end.day
		):
			return true
	return false


func does_market_start_today() -> bool:
	for market_period: Dictionary in MARKET_PERIODS:
		if date.month == market_period.start.month and date.day == market_period.start.day:
			return true
	return false


func does_market_end_today() -> bool:
	for market_period: Dictionary in MARKET_PERIODS:
		if date.month == market_period.end.month and date.day == market_period.end.day:
			return true
	return false


func is_season_finished() -> bool:
	return date.month == SEASON_END_MONTH and date.day == SEASON_END_DAY


func format_date(p_date: Dictionary = date) -> String:
	return FormatUtil.format_date(p_date)


func get_next_match() -> Match:
	for matchz: Match in day().get_matches():
		if matchz.home_id == Global.team.id or matchz.away_id == Global.team.id:
			return matchz
	return null


func _add_year(year: int) -> void:
	# start date in fomrat YYYY-MM-DDTHH:MM:SS
	var first_january: String = str(year) + "-01-01T00:00:00"
	var temp_date: Dictionary = Time.get_datetime_dict_from_datetime_string(first_january, true)
	# create months
	for month_string: String in Enum.Months:
		var new_month: Month = Month.new()
		new_month.name = month_string
		months.append(new_month)

	var month_shift: int = (year - date.year) * 12
	while temp_date.year == year:
		var new_day: Day = Day.new()
		new_day.market = is_market_active(temp_date)
		new_day.weekday = temp_date.weekday
		new_day.day = temp_date.day
		new_day.month = temp_date.month
		new_day.year = temp_date.year
		months[temp_date.month - 1 + month_shift].days.append(new_day)

		temp_date = _get_next_day(temp_date)


func _get_next_day(p_date: Dictionary = date) -> Dictionary:
	# increment date by one day
	var unix_time: int = Time.get_unix_time_from_datetime_dict(p_date)
	unix_time += DAY_IN_SECONDS
	var next_day_date: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)

	next_day_date.erase("hour")
	next_day_date.erase("minute")
	next_day_date.erase("second")

	return next_day_date
