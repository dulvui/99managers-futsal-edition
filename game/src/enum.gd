# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

# singleton for enums with string conversion functions
# because pot generation doesn't detect enum keys as strings

#
# Generation
#
enum PlayerNames {
	MALE,
	FEMALE,
	MIXED,
}

#
# Players
#
enum Foot { LEFT, RIGHT, LEFT_AND_RIGHT }
enum Morality { WORST, BAD, NEUTRAL, GOOD, BEST }
enum Form { INJURED, RECOVER, GOOD, BEST }

#
# Match
#
enum MatchSpeed {
	FULL_GAME,
	KEY_ACTIONS,
	ONLY_GOALS,
}

#
# Calendar
#
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
# Input
#
enum InputDetectionMode {
	AUTO,
	MANUAL,
}

enum InputType {
	JOYPAD,
	MOUSE_AND_KEYBOARD,
	TOUCHSCREEN,
}

var input_detection_mode: Array[String] = ["Automatic", "Manual"]


#
# get text functions
#
func get_match_speed_text() -> String:
	match Global.match_speed:
		MatchSpeed.FULL_GAME:
			return tr("Full game")
		MatchSpeed.KEY_ACTIONS:
			return tr("Key actions")
		MatchSpeed.ONLY_GOALS:
			return tr("Only goals")
		_:
			return tr("Full game")


func get_player_names_text(player_names: PlayerNames = Global.generation_player_names) -> String:
	match player_names:
		PlayerNames.MALE:
			return tr("Male")
		PlayerNames.FEMALE:
			return tr("Female")
		PlayerNames.MIXED:
			return tr("Mixed")
		_:
			return tr("Mixed")


func get_month_text(month: Months, short: bool = false) -> String:
	var month_text: String

	match month:
		Months.JANUARY:
			month_text = tr("January")
		Months.FEBRUARY:
			month_text = tr("February")
		Months.MARCH:
			month_text = tr("March")
		Months.APRPIL:
			month_text = tr("April")
		Months.MAY:
			month_text = tr("May")
		Months.JUNE:
			month_text = tr("June")
		Months.JULY:
			month_text = tr("July")
		Months.AUGUST:
			month_text = tr("August")
		Months.SEPTEMBER:
			month_text = tr("September")
		Months.OCTOBER:
			month_text = tr("October")
		Months.NOVEMBER:
			month_text = tr("November")
		Months.DECEMBER:
			month_text = tr("December")

	if short:
		return month_text.substr(0, 3)
	return month_text


func get_weekday_text(weekday: Weekdays, short: bool = false) -> String:
	var weekday_text: String

	match weekday:
		Weekdays.MONDAY:
			weekday_text = tr("Monday")
		Weekdays.TUESDAY:
			weekday_text = tr("Tuesday")
		Weekdays.WEDNESDAY:
			weekday_text = tr("Wednesday")
		Weekdays.THURSDAY:
			weekday_text = tr("Thursday")
		Weekdays.FRIDAY:
			weekday_text = tr("Friday")
		Weekdays.SATURDAY:
			weekday_text = tr("Saturday")
		Weekdays.SUNDAY:
			weekday_text = tr("Sunday")

	if short:
		return weekday_text.substr(0, 3)
	return weekday_text


func get_input_detection_type_text() -> String:
	match Global.config.input_detection_mode:
		InputDetectionMode.AUTO:
			return tr("Automatic")
		InputDetectionMode.MANUAL:
			return tr("Manual")
		_:
			return tr("Automatic")


func get_input_type_text() -> String:
	match Global.config.input_type:
		InputType.MOUSE_AND_KEYBOARD:
			return tr("Mouse and Keyboard")
		InputType.JOYPAD:
			return tr("Joypad")
		InputType.TOUCHSCREEN:
			return tr("Touchscreen")
		_:
			return tr("Mouse and Keyboard")


func get_foot_text(player: Player) -> String:
	match player.foot:
		Foot.LEFT:
			return tr("Left")  # TRANSLATORS: Preferred foot
		Foot.RIGHT:
			return tr("Right")  # TRANSLATORS: Preferred foot
		Foot.LEFT_AND_RIGHT:
			return tr("Left and right")  # TRANSLATORS: Preferred foot
		_:
			return tr("Right")  # TRANSLATORS: Preferred foot


func get_morality_text(player: Player) -> String:
	match player.morality:
		Morality.WORST:
			return tr("Worst")  # TRANSLATORS: Player morality
		Morality.BAD:
			return tr("Bad")  # TRANSLATORS: Player morality
		Morality.NEUTRAL:
			return tr("Neutral")  # TRANSLATORS: Player morality
		Morality.GOOD:
			return tr("Good")  # TRANSLATORS: Player morality
		Morality.BEST:
			return tr("Best")  # TRANSLATORS: Player morality
		_:
			return tr("Neutral")  # TRANSLATORS: Player morality


func get_form_text(player: Player) -> String:
	match player.form:
		Form.INJURED:
			return tr("Injured")  # TRANSLATORS: Player physical form
		Form.RECOVER:
			return tr("Recover")  # TRANSLATORS: Player physical form
		Form.GOOD:
			return tr("Good")  # TRANSLATORS: Player physical form
		Form.BEST:
			return tr("Best")  # TRANSLATORS: Player physical form
		_:
			return tr("Good")  # TRANSLATORS: Player physical form
