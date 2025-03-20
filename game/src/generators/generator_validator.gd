# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorValidator

const MAX_FILE_SIZE: int = 1000000 # 1MB
const HEADERS: Array[String] = ["NATION", "LEAGUE", "TEAM"]


func validate_csv_file(file_path: String) -> bool:
	# open file
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var error: Error = file.get_error()
	if error != OK:
		push_error("error while opening csv file at %s" % file_path)
		Global.generation_errors.append(Enum.GenerationError.ERR_READ_FILE)
		return false


	var file_size: int = file.get_length()
	if file_size > MAX_FILE_SIZE:
		push_error("error csv file too big. size %d bytes" % file_size)
		Global.generation_errors.append(Enum.GenerationError.ERR_FILE_TOO_BIG)
		return false

	# read as text to see if utf8
	# var text: String = file.get_as_text()
	file.get_as_text()
	error = file.get_error()
	if error != OK:
		push_error("error while reading file as text. error %d" % error)
		Global.generation_errors.append(Enum.GenerationError.ERR_FILE_NOT_UTF8)
		return false

	# validate header row CONTINENT, NATION, CITY, TEAM
	# check size
	var header_line: PackedStringArray = file.get_csv_line()
	if header_line.size() != HEADERS.size():
		push_error("error csv file has wrong header amount")
		Global.generation_errors.append(Enum.GenerationError.ERR_CSV_HEADER_SIZE)
		return false
	# check order and format
	for i: int in header_line.size():
		var header: String = header_line[i]
		header = header.to_upper()
		header = header.replace(" ", "")
		if header != HEADERS[i]:
			push_error("error csv header wrong format. expecetd %s but found %s" % [HEADERS[i], header])
			Global.generation_errors.append(Enum.GenerationError.ERR_CSV_HEADER_FORMAT)
			return false

	# text server for validation
	var text_server: TextServer = TextServerManager.get_primary_interface()
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()

		error = file.get_error()
		if error == Error.ERR_FILE_EOF:
			break

		# check for errors
		if error != Error.OK:
			push_error("error while reading lines from csv with code %d" % error)
			Global.generation_errors.append(Enum.GenerationError.ERR_READ_FILE)
			return false
	
		# check columns size same as headers
		if line.size() != HEADERS.size():
			push_error("wrong column size in row %d" % error)
			Global.generation_errors.append(Enum.GenerationError.ERR_COLUMN_SIZE)
			return false

		# check if string is valid utf8 character
		for string: String in line:
			if not _is_valid_string(string, text_server):
				push_error("not valid string found: %s" % string)
				Global.generation_errors.append(Enum.GenerationError.ERR_CSV_INVALID_FORMAT)
				return false
	return true


func validate_world(world: World) -> bool:
	# check league size
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				# max amount check
				if league.teams.size() > Const.LEAGUE_MAX_TEAMS:
					push_warning("too many teams in league " + league.name)
					Global.generation_warnings.append(Enum.GenerationWarning.WARN_LEAGUE_SIZE_MAX)
					league.teams = league.teams.slice(0, Const.LEAGUE_MAX_TEAMS)

				# even amount check
				if league.teams.size() % 2 == 1:
					push_warning("odd team amounts in league " + league.name)
					Global.generation_warnings.append(Enum.GenerationWarning.WARN_LEAGUE_SIZE_ODD)
					# remove last team
					league.teams = league.teams.slice(0, league.teams.size())

				# min amount check
				if league.teams.size() < Const.LEAGUE_MIN_TEAMS:
					push_warning("too few teams in league " + league.name)
					Global.generation_errors.append(Enum.GenerationError.ERR_LEAGUE_SIZE_MIN)
					return false

	# check if at least one continent is competitive, after league check
	var competitive_continent_found: bool = false
	for continent: Continent in world.continents:
		if continent.is_competitive():
			competitive_continent_found = true
			break
	if not competitive_continent_found:
		push_error("world has no competitive continent")
		Global.generation_errors.append(Enum.GenerationError.ERR_LEAGUE_NO_VALID)
		return false

	return true


func _is_valid_string(string: String, text_server: TextServer) -> bool:
	if string.is_empty():
		return true
	if string.is_valid_float():
		return true

	# check if valid unicode
	for i: int in string.length():
		var unicode_char: int = string.unicode_at(i)
		# space
		if unicode_char == 32:
			return true
		# comma
		if unicode_char == 44:
			return true
		# hyphen
		if unicode_char == 45:
			return true
		# colon
		if unicode_char == 58:
			return true

		var valid_letter: bool = text_server.is_valid_letter(unicode_char)
		var valid_number: bool = string[i].is_valid_float()

		if not valid_letter and not valid_number:
			print("csv line not vaild: %s" % string)
			print("not allowed unicode sign: %s code: %d" % [char(unicode_char), unicode_char])
			return false

	return true
