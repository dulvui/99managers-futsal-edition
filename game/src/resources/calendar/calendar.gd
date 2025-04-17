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

const MARKET_WINTER_START_DAY: int = 1
const MARKET_WINTER_START_MONTH: int = 1
const MARKET_WINTER_END_DAY: int = 31
const MARKET_WINTER_END_MONTH: int = 1

const MARKET_SUMMER_START_DAY: int = 1
const MARKET_SUMMER_START_MONTH: int = 6
const MARKET_SUMMER_END_DAY: int = 31
const MARKET_SUMMER_END_MONTH: int = 8

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
		date = Global.start_date

	# set start date
	date.day = Const.SEASON_START_DAY
	date.month = Const.SEASON_START_MONTH
	
	# clear previous season, if exists
	months = []

	# always add two years to calendar
	var year: int = date.year
	_add_year(year)
	_add_year(year + 1)


func next_day() -> void:
	date = _get_next_day()


func day(p_month: int = date.month, p_day: int = date.day) -> Day:
	return months[p_month - 1].days[p_day - 1]


func month(p_month: int = date.month) -> Month:
	return months[p_month - 1]


func days_difference(p_date_1: Dictionary, p_date_2: Dictionary = date) -> int:
	var unix_1: int = Time.get_unix_time_from_datetime_dict(p_date_1)
	var unix_2: int = Time.get_unix_time_from_datetime_dict(p_date_2)

	var difference: float = unix_2 - unix_1
	# divide with seconds of day
	difference = difference / 86400.0
	return int(difference)


func is_market_active(p_date: Dictionary = date) -> bool:
	if p_date.month >= MARKET_WINTER_START_MONTH and p_date.month <= MARKET_WINTER_END_MONTH and \
		p_date.day >= MARKET_WINTER_START_DAY and p_date.day <= MARKET_WINTER_END_DAY:
			return true
	if p_date.month >= MARKET_SUMMER_START_MONTH and p_date.month <= MARKET_SUMMER_END_MONTH and \
		p_date.day >= MARKET_SUMMER_START_DAY and p_date.day <= MARKET_SUMMER_END_DAY:
			return true
	return false


func does_market_start_today() -> bool:
	if date.month == MARKET_WINTER_START_MONTH and date.day == MARKET_WINTER_START_DAY:
		return true
	if date.month == MARKET_SUMMER_START_MONTH and date.day == MARKET_SUMMER_START_DAY:
		return true
	return false


func does_market_end_today() -> bool:
	if date.month == MARKET_WINTER_END_MONTH and date.day == MARKET_WINTER_END_DAY:
		return true
	if date.month == MARKET_SUMMER_END_MONTH and date.day == MARKET_WINTER_END_DAY:
		return true
	return false


func is_season_finished() -> bool:
	return date.month == SEASON_END_MONTH and date.day == SEASON_END_DAY


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

