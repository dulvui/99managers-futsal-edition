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
enum Weekdays {
	SUNDAY,
	MONDAY,
	TUESDAY,
	WEDNESDAY,
	THURSDAY,
	FRIDAY,
	SATURDAY,
}


enum InputType {
	MOUSE_AND_KEYBOARD,
	JOYPAD,
	TOUCHSCREEN,
}


#
# text vars
#
var offer_timings: Array[String] = ["Immediate", "Next transfer window"]
var player_names: Array[String] = ["Male", "Female","Mixed"]
var input_type: Array[String] = ["Mouse and keyboard", "Joypad", "Touchscreen"]


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

# keep here, even if no enum, for now...
func get_month_text(p_month: int, short: bool = false) -> String:
	var month_text: String

	while p_month > 12:
		if p_month % 12 == 0:
			p_month = 12
		else:
			p_month = p_month % 12

	match p_month:
		1:
			month_text = tr("January")
		2:
			month_text = tr("February")
		3:
			month_text = tr("March")
		4:
			month_text = tr("April")
		5:
			month_text = tr("May")
		6:
			month_text = tr("June")
		7:
			month_text = tr("July")
		8:
			month_text = tr("August")
		9:
			month_text = tr("September")
		10:
			month_text = tr("October")
		11:
			month_text = tr("November")
		12:
			month_text = tr("December")
		_:
			push_error("error while getting month text for month %d" % p_month)
			month_text = "ERROR"

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


func get_morality_text(player: Player) -> String:
	match player.morality:
		Morality.WORST:
			return tr("Worst") # TRANSLATORS: Player morality
		Morality.BAD:
			return tr("Bad") # TRANSLATORS: Player morality
		Morality.NEUTRAL:
			return tr("Neutral") # TRANSLATORS: Player morality
		Morality.GOOD:
			return tr("Good") # TRANSLATORS: Player morality
		Morality.BEST:
			return tr("Best") # TRANSLATORS: Player morality
		_:
			return tr("Neutral") # TRANSLATORS: Player morality


func get_form_text(player: Player) -> String:
	match player.form:
		Form.INJURED:
			return tr("Injured") # TRANSLATORS: Player physical form
		Form.RECOVER:
			return tr("Recover") # TRANSLATORS: Player physical form
		Form.GOOD:
			return tr("Good") # TRANSLATORS: Player physical form
		Form.BEST:
			return tr("Best") # TRANSLATORS: Player physical form
		_:
			return tr("Good") # TRANSLATORS: Player physical form


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


func get_position_type_text(p_type: Position.Type) -> String:
	match p_type:
		Position.Type.G:
			return tr("G")
		Position.Type.DL:
			return tr("DL")
		Position.Type.DC:
			return tr("DC")
		Position.Type.DR:
			return tr("DR")
		Position.Type.C:
			return tr("C")
		Position.Type.WL:
			return tr("WL")
		Position.Type.WR:
			return tr("WR")
		Position.Type.PL:
			return tr("PL")
		Position.Type.PC:
			return tr("PC")
		Position.Type.PR:
			return tr("PR")
	return ""


func get_position_type_from_string(string: String) -> Position.Type:
	if string == null or string.is_empty():
		return Position.Type.UNDEFINED

	match string.to_upper():
		"G":
			return Position.Type.G
		"DL":
			return Position.Type.DL
		"DC":
			return Position.Type.DC
		"DR":
			return Position.Type.DR
		"C":
			return Position.Type.C
		"WL":
			return Position.Type.WL
		"WR":
			return Position.Type.WR
		"PL":
			return Position.Type.PL
		"PC":
			return Position.Type.PC
		"PR":
			return Position.Type.PR
		_:
			return Position.Type.UNDEFINED


func get_offer_timing_text(timing: Offer.Timing) -> String:
	match timing:
		Offer.Timing.IMMEDIATE:
			return tr("Immediate")
		Offer.Timing.NEXT_WINDOW:
			return tr("Next transfer window")
	return tr("Immediate")

