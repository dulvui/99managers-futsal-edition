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
enum Foot { LEFT, RIGHT, LEFT_AND_RIGHT	}
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


#
# get text functions
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


func get_input_detection_type_text() -> String:
	match Global.input_detection_mode:
		InputDetectionMode.AUTO:
			return tr("AUTOMATIC")
		InputDetectionMode.MANUAL:
			return tr("MANUAL")
		_:
			return tr("AUTOMATIC")


func get_input_type_text() -> String:
	match Global.input_type:
		InputType.MOUSE_AND_KEYBOARD:
			return tr("MOUSE_AND_KEYBOARD")
		InputType.JOYPAD:
			return tr("JOYPAD")
		InputType.TOUCHSCREEN:
			return tr("TOUCHSCREEN")
		_:
			return tr("MOUSE_AND_KEYBOARD")


func get_foot_text(player: Player) -> String:
	match player.foot:
		Foot.LEFT:
			return tr("LEFT") # TRANSLATORS: Preferred foot
		Foot.RIGHT:
			return tr("RIGHT") # TRANSLATORS: Preferred foot
		Foot.LEFT_AND_RIGHT:
			return tr("LEFT_AND_RIGHT") # TRANSLATORS: Preferred foot
		_:
			return tr("RIGHT") # TRANSLATORS: Preferred foot


func get_morality_text(player: Player) -> String:
	match player.morality:
		Morality.WORST:
			return tr("WORST") # TRANSLATORS: Player morality
		Morality.BAD:
			return tr("BAD") # TRANSLATORS: Player morality
		Morality.NEUTRAL:
			return tr("NEUTRAL") # TRANSLATORS: Player morality
		Morality.GOOD:
			return tr("GOOD") # TRANSLATORS: Player morality
		Morality.BEST:
			return tr("BEST") # TRANSLATORS: Player morality
		_:
			return tr("NEUTRAL") # TRANSLATORS: Player morality


func get_form_text(player: Player) -> String:
	match player.form:
		Form.INJURED:
			return tr("INJURED") # TRANSLATORS: Player physical form
		Form.RECOVER:
			return tr("RECOVER") # TRANSLATORS: Player physical form
		Form.GOOD:
			return tr("GOOD") # TRANSLATORS: Player physical form
		Form.BEST:
			return tr("BEST") # TRANSLATORS: Player physical form
		_:
			return tr("GOOD") # TRANSLATORS: Player physical form
