# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum Currencies { EURO, DOLLAR, POUND, BITCOIN }
enum Dates {
	DMY_SLASH, DMY_DOT, DMY_HYPHEN,
	MDY_SLASH, MDY_DOT, MDY_HYPHEN,
	YMD_SLASH,
}

const SIGNS: Array[String] = ["€", "$", "£", "₿"]
const SIGNS_TEXT: Array[String] = ["Euro €", "Dollar $", "Pound £", "Bitcoin ₿"]
const DATES_EXAMPLES: Array[String] = [
	"31/12/2000","31.12.2000","31-12-2000",
	"12/31/2000","12.31.2000","12-31-2000",
	"2000-12-31",
]


func currency(amount: int) -> String:
	return number(amount) + " " + SIGNS[Global.config.currency]


func day(p_date: Dictionary) -> String:
	if "day" in p_date and "month" in p_date and "year" in p_date:
		var p_day: int = p_date.day
		var p_month: int = p_date.month
		var p_year: int = p_date.year
		return date(p_day, p_month, p_year)
	return ""


func date(p_day: int, p_month: int, p_year: int = -1) -> String:
	# short
	if p_year == -1:
		match Global.config.date:
			Dates.DMY_SLASH, Dates.DMY_DOT, Dates.DMY_HYPHEN, Dates.YMD_SLASH:
				return "%d/%d" % [p_day, p_month]
			_:
				return "%d/%d" % [p_month, p_month]
	# long
	match Global.config.date:
		Dates.DMY_SLASH:
			return "%d/%d/%d" % [p_day, p_month, p_year]
		Dates.DMY_DOT:
			return "%d.%d.%d" % [p_day, p_month, p_year]
		Dates.DMY_HYPHEN:
			return "%d-%d-%d" % [p_day, p_month, p_year]
		Dates.MDY_SLASH:
			return "%d/%d/%d" % [p_month, p_day, p_year]
		Dates.MDY_DOT:
			return "%d.%d.%d" % [p_month, p_day, p_year]
		Dates.MDY_HYPHEN:
			return "%d-%d-%d" % [p_month, p_day, p_year]
		Dates.YMD_SLASH:
			return "%d-%d-%d" % [p_year, p_month, p_day]
		_:
			return "%d/%d/%d" % [p_day, p_month, p_year]


func day_from_string(p_date: String) -> Dictionary:
	var date_parts: PackedStringArray = p_date.split("/")
	if date_parts.size() != 3:
		push_error("date string has wrong format %s" % p_date)
		return {}

	return {
		"day": int(date_parts[0]),
		"month": int(date_parts[1]),
		"year": int(date_parts[2]),
	}


func number(value: int) -> String:
	var formatted: String = str(value)
	var string: String = str(value)

	for i: int in range(string.length(), 0, -3):
		formatted = formatted.substr(0, i) + " " + formatted.substr(i)

	formatted = formatted.rstrip(" ")
	# print(string + " becomes '" + formatted + "'")
	return formatted

