# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Day
extends JSONResource

@export var market: bool
@export var weekday: Enum.Weekdays
@export var day: int
@export var month: Enum.Months
@export var year: int


func _init(
	p_market: bool = false,
	p_weekday: Enum.Weekdays = Enum.Weekdays.THURSDAY,
	p_day: int = 1,
	p_month: Enum.Months = Enum.Months.JANUARY,
	p_year: int = 1970,
) -> void:
	market = p_market
	weekday = p_weekday
	day = p_day
	month = p_month
	year = p_year


func to_format_string(long: bool = false) -> String:
	if long:
		return (
			Enum.get_weekday_text(weekday)
			+ " "
			+ str(day)
			+ " "
			+ Enum.get_month_text(month - 1)
			+ " "
			+ str(year)
		)
	return (
		str(day)
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
