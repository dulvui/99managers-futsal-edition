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

var player_names: Array[String] = ["Male", "Female","Mixed"]

enum GenerationError {
	ERR_READ_FILE,
	ERR_FILE_TOO_BIG,
	ERR_FILE_NOT_UTF8,
	ERR_CSV_INVALID_FORMAT,
	ERR_CSV_HEADER_SIZE,
	ERR_CSV_HEADER_FORMAT,
	ERR_COLUMN_SIZE,
	ERR_LEAGUE_NO_VALID,
	ERR_LEAGUE_SIZE_MIN,
}

enum GenerationWarning {
	WARN_NATION_FORMAT,
	WARN_NATION_NOT_FOUND,
	WARN_LEAGUE_SIZE_MAX,
	WARN_LEAGUE_SIZE_ODD,
	WARN_TEAM_NO_NAME,
	WARN_LEAGUE_NO_NAME,
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
var input_detection_mode: Array[String] = ["Automatic", "Manual"]

enum InputType {
	JOYPAD,
	MOUSE_AND_KEYBOARD,
	TOUCHSCREEN,
}

var input_type: Array[String] = ["Joypad", "Mouse and keybaord","Touchscreen"]


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


func get_player_names_text(p_player_names: PlayerNames = Global.generation_player_names) -> String:
	match p_player_names:
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


func get_generation_error_text(error: GenerationError) -> String:
	match error:
		GenerationError.ERR_READ_FILE:
			return tr("Unable to read file.")
		GenerationError.ERR_CSV_INVALID_FORMAT:
			return tr("Invalid csv format.")
		GenerationError.ERR_FILE_TOO_BIG:
			return tr("File too big. Max file size is {file_size}")
		GenerationError.ERR_FILE_NOT_UTF8:
			return tr("File has non valid characters.")
		GenerationError.ERR_CSV_HEADER_SIZE:
			return tr("Wrong amount of headers in first line, expected {header_size}")
		GenerationError.ERR_CSV_HEADER_FORMAT:
			return tr("Wrong format of headers in first line, expected {headers}")
		GenerationError.ERR_LEAGUE_NO_VALID:
			return tr("No vaild league was found in file.")
		GenerationError.ERR_LEAGUE_SIZE_MIN:
			return tr("League {league_name} has less than 8 teams.")
		_:
			return tr("Undefined error occurred.")


func get_generation_warning_text(warning: GenerationWarning) -> String:
	match warning:
		GenerationWarning.WARN_NATION_FORMAT:
			return tr("Nation {nation_name} has wrong format")
		GenerationWarning.WARN_NATION_NOT_FOUND:
			return tr("Nation {nation_name} not found")
		GenerationWarning.WARN_LEAGUE_SIZE_MAX:
			return tr("League {league_name} has more than 20 teams.")
		GenerationWarning.WARN_LEAGUE_SIZE_ODD:
			return tr("League {league_name} has odd size teams.")
		GenerationWarning.WARN_LEAGUE_NO_NAME:
			return tr("League with no name defined in line {line_number}")
		GenerationWarning.WARN_TEAM_NO_NAME:
			return tr("Team with no name defined in line {line_number}")
		_:
			return tr("Undefined warning occurred.")
