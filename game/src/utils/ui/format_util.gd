# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum Currencies { EURO, DOLLAR, POUND, BITCOIN }

const SIGNS: Array = ["€", "$", "£", "₿"]


func currency(amount: int) -> String:
	return number(amount) + " " + SIGNS[Global.config.currency]


func day(p_date: Dictionary) -> String:
	var p_day: int = p_date.day
	var p_month: int = p_date.month
	var p_year: int = p_date.year
	return date(p_day, p_month, p_year)


func date(p_day: int, p_month: int, p_year: int = -1) -> String:
	if p_year == -1:
		return "%d/%d" % [p_day, p_month]
	return "%d/%d/%d" % [p_day, p_month, p_year]


func number(value: int) -> String:
	var formatted: String = str(value)
	var string: String = str(value)

	for i: int in range(string.length(), 0, -3):
		formatted = formatted.substr(0, i) + " " + formatted.substr(i)

	formatted = formatted.rstrip(" ")
	# print(string + " becomes '" + formatted + "'")
	return formatted

