# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum Currencies { EURO, DOLLAR, POUND, BITCOIN }

const SIGNS: Array = ["€", "$", "£", "₿"]


func currency(amount: int) -> String:
	return format_number(amount) + " " + SIGNS[Global.config.currency]


func format_date(p_date: Dictionary) -> String:
	return (
		tr(Enum.get_weekday_text(p_date.weekday))
		+ " "
		+ tr(str(int(p_date.day)))
		+ " "
		+ tr(Enum.get_month_text(p_date.month - 1))
		+ " "
		+ str(int(p_date.year))
	)


func format_number(number: int) -> String:
	var formatted: String = str(number)
	var string: String = str(number)

	for i: int in range(string.length(), 0, -3):
		formatted = formatted.substr(0, i) + " " + formatted.substr(i)

	formatted = formatted.rstrip(" ")
	# print(string + " becomes '" + formatted + "'")
	return formatted
