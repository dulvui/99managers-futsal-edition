# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

# singleton for enums with string conversion functions
# because pot generation doesn't detect enum keys as strings

enum PlayerNames {
	MALE,
	FEMALE,
	MIXED,
}

enum MatchSpeed {
	FULL_GAME,
	KEY_ACTIONS,
	ONLY_GOALS,
}

enum Months {
	JANUARY,
	FEBRUARY,
	MARCH,
	APRPIL,
	MAY,
	JUNE,
	JULY,
	AUGUST,
	SEPTEMBER,
	OCTOBER,
	NOVEMBER,
	DECEMBER,
}

enum Weekdays {
	SUNDAY,
	MONDAY,
	TUESDAY,
	WEDNESDAY,
	THURSDAY,
	FRIDAY,
	SATURDAY,
}

#
# Enum text functions
#
func get_match_speed_text() -> String:
	match Global.match_speed:
		MatchSpeed.FULL_GAME:
			return tr("FULL_GAME")
		MatchSpeed.KEY_ACTIONS:
			return tr("KEY_ACTIONS")
		MatchSpeed.ONLY_GOALS:
			return tr("ONLY_GOALS")
		_:
			return tr("FULL_GAME")


func get_generation_player_names_text() -> String:
	match Global.generation_player_names:
		PlayerNames.MALE:
			return tr("MALE")
		PlayerNames.FEMALE:
			return tr("FEMALE")
		PlayerNames.MIXED:
			return tr("MIXED")
		_:
			return tr("MIXED")


func get_month_text(month: Months, short: bool = false) -> String:
	var month_text: String

	match month:
		Months.JANUARY:
			month_text = tr("JANUARY")
		Months.FEBRUARY:
			month_text = tr("FEBRUARY")
		Months.MARCH:
			month_text = tr("MARCH")
		Months.APRPIL:
			month_text = tr("APRIL")
		Months.MAY:
			month_text = tr("MAY")
		Months.JUNE:
			month_text = tr("JUNE")
		Months.JULY:
			month_text = tr("JULY")
		Months.AUGUST:
			month_text = tr("AUGUST")
		Months.SEPTEMBER:
			month_text = tr("SEPTEMBER")
		Months.OCTOBER:
			month_text = tr("OCTOBER")
		Months.NOVEMBER:
			month_text = tr("NOVEMBER")
		Months.DECEMBER:
			month_text = tr("DECEMBER")
	
	if short:
		return month_text.substr(0, 3)
	return month_text


func get_weekday_text(weekday: Weekdays, short: bool = false) -> String:
	var weekday_text: String

	match weekday:
		Weekdays.MONDAY:
			weekday_text = tr("MONDAY")
		Weekdays.TUESDAY:
			weekday_text = tr("TUESDAY")
		Weekdays.WEDNESDAY:
			weekday_text = tr("WEDNESDAY")
		Weekdays.THURSDAY:
			weekday_text = tr("THURSDAY")
		Weekdays.FRIDAY:
			weekday_text = tr("FRIDAY")
		Weekdays.SATURDAY:
			weekday_text = tr("SATURDAY")
		Weekdays.SUNDAY:
			weekday_text = tr("SUNDAY")
	
	if short:
		return weekday_text.substr(0, 3)
	return weekday_text


