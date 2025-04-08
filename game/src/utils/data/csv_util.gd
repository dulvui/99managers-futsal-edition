# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVUtil

const COMPRESSION_ON: bool = false
const COMPRESSION_MODE: FileAccess.CompressionMode = FileAccess.CompressionMode.COMPRESSION_GZIP
const MAX_FILE_SIZE: int = 1_000_000 # 100MB

var backup_util: BackupUtil
var headers: CSVHeaders


func _init() -> void:
	backup_util = BackupUtil.new()
	headers = CSVHeaders.new()


func initialize_world(csv_path: String, world: World) -> void:
	var csv: Array[PackedStringArray] = read_csv(csv_path)
	csv_to_players(csv, world)


func players_to_csv(world: World) -> Array[PackedStringArray]:
	var lines: Array[PackedStringArray] = []

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					for player: Player in team.players:
						var player_line: PackedStringArray = PackedStringArray()
						# team
						player_line.append(nation.code)
						player_line.append(league.name)
						player_line.append(team.name)
						player_line.append(str(team.finances.balance))
						player_line.append(team.stadium.name)
						player_line.append(str(team.stadium.capacity))
						player_line.append(str(team.stadium.year_built))
						
						# player
						player_line.append(player.name)
						player_line.append(player.surname)
						player_line.append(str(player.value))
						player_line.append(FormatUtil.day(player.birth_date))
						player_line.append(player.nation)
						player_line.append(str(player.nr))
						player_line.append(str(player.foot_left))
						player_line.append(str(player.foot_right))
						player_line.append(player.position.get_type_text())
						var alt_positions: Array[StringName] = []
						for position: Position in player.alt_positions:
							alt_positions.append(position.get_type_text())
						player_line.append(_array_to_csv_list(alt_positions))
						player_line.append(str(player.injury_factor))
						# add double quotes so that sheet editors see it as strings and not numbers
						player_line.append("\"%s\"" % player.eyecolor)
						player_line.append("\"%s\"" % player.haircolor)
						player_line.append("\"%s\"" % player.skintone)

						# attributes
						player_line.append_array(res_to_line(player.attributes.goalkeeper, headers.PLAYER_ATTRIBUTES_GOALKEEPER))
						player_line.append_array(res_to_line(player.attributes.mental, headers.PLAYER_ATTRIBUTES_MENTAL))
						player_line.append_array(res_to_line(player.attributes.physical, headers.PLAYER_ATTRIBUTES_PHYSICAL))
						player_line.append_array(res_to_line(player.attributes.technical, headers.PLAYER_ATTRIBUTES_TECHNICAL))

						lines.append(player_line)

	var csv: Array[PackedStringArray] = []
	csv.append(headers.list)
	csv.append_array(lines)

	return csv


func csv_to_players(csv: Array[PackedStringArray], world: World) -> void:
	# last values found in last line read
	# can be reused for next line, since lines most likely are grouped by team
	var nation: Nation = null
	var league: League = null
	var team: Team = null

	# remove header
	csv.pop_front()

	var line_index: int = 0
	for line: PackedStringArray in csv:
		line_index += 1

		if line.size() < 3:
			continue

		# team
		var nation_code: String = _get_string_or_default(line, 0)
		var league_name: String = _get_string_or_default(line, 1)
		var team_name: String = _get_string_or_default(line, 2)
		var team_budget: int = _get_int_or_default(line, 3)
		var stadium_name: String = _get_string_or_default(line, 4)
		var stadium_capacity: int = _get_int_or_default(line, 5)
		var stadium_year_built: int = _get_int_or_default(line, 6)
		# player
		var name: String = _get_string_or_default(line, 7)
		var surname: String = _get_string_or_default(line, 8)
		var value: String = _get_string_or_default(line, 9)
		var birth_date: String = _get_string_or_default(line, 10)
		var nationality: String = _get_string_or_default(line, 11)
		var nr: int = _get_int_or_default(line, 12)
		var foot_left: int = _get_int_or_default(line, 13)
		var foot_right: int = _get_int_or_default(line, 14)
		var position: String = _get_string_or_default(line, 15)
		var alt_positions: String = _get_string_or_default(line, 16)
		var injury_factor: int = _get_int_or_default(line, 17)
		var eyecolor: String = _get_string_or_default(line, 18)
		var haircolor: String = _get_string_or_default(line, 19)
		var skintone: String = _get_string_or_default(line, 16)

		# nation
		if nation == null or nation.code != nation_code:
			nation = world.get_nation_by_code(nation_code)
		if nation == null:
			push_error("no nation with code \"%s\" found in line %d" % [nation_code, line_index])
			continue

		# league
		if league == null or league.name != league_name:
			league = world.get_league_by_name(league_name, nation)
		if league == null:
			league = League.new()
			league.set_id()
			league.name = league_name
			league.pyramid_level = nation.leagues.size() + 1
			nation.leagues.append(league)

		# team
		if team == null or team.name != team_name:
			team = league.get_team_by_name(team_name)
		if team == null:
			team = Team.new()
			team.set_id()
			team.name = team_name
			team.finances.balance[-1] = team_budget
			team.stadium.name = stadium_name
			team.stadium.capacity = stadium_capacity
			team.stadium.year_built = stadium_year_built

			league.add_team(team)


		# player
		if name.is_empty() or surname.is_empty():
			continue
		
		var player: Player = Player.new()
		player.set_id()
		player.name = name
		player.surname = surname
		player.value = int(value)
		player.team = team_name
		player.birth_date = FormatUtil.day_from_string(birth_date)
		player.nation = nationality
		player.nr = int(nr)
		player.foot_left = int(foot_left)
		player.foot_right = int(foot_right)
		player.position = Position.new()
		player.position.set_type_from_string(position)
		alt_positions = alt_positions.replace("\"", "")
		var alt_positions_array: PackedStringArray = alt_positions.split(",")
		for alt_position_string: String in alt_positions_array:
			var alt_position: Position = Position.new()
			alt_position.set_type_from_string(alt_position_string)
			player.alt_positions.append(alt_position)
		player.injury_factor = int(injury_factor)
		# remove quotes
		player.eyecolor = eyecolor.replace("\"", "")
		player.haircolor = haircolor.replace("\"", "")
		player.skintone = skintone.replace("\"", "")

		# next values are attributes
		# attributes get set by iterating over attribute name arrays/headers
		var column_index: int = headers.attributes_start
		# attributes
		for attribute: String in headers.PLAYER_ATTRIBUTES_GOALKEEPER:
			player.attributes.goalkeeper.set(attribute, _get_int_or_default(line, column_index))
			column_index += 1
		for attribute: String in headers.PLAYER_ATTRIBUTES_MENTAL:
			player.attributes.mental.set(attribute, _get_int_or_default(line, column_index))
			column_index += 1
		for attribute: String in headers.PLAYER_ATTRIBUTES_PHYSICAL:
			player.attributes.physical.set(attribute, _get_int_or_default(line, column_index))
			column_index += 1
		for attribute: String in headers.PLAYER_ATTRIBUTES_TECHNICAL:
			player.attributes.technical.set(attribute, _get_int_or_default(line, column_index))
			column_index += 1

		team.players.append(player)


# use result, since on next call array will be reused for performance
func res_to_line(resource: Resource, p_headers: PackedStringArray) -> PackedStringArray:
	var line: PackedStringArray = PackedStringArray()

	for header: String in p_headers:
		var value: Variant = resource.get(header)
		if value == null:
			line.append("")
		else:
			line.append(str(value))

	return line


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
	if header_line.size() != headers.size:
		push_error("error csv file has wrong header amount")
		Global.generation_errors.append(Enum.GenerationError.ERR_CSV_HEADER_SIZE)
		return false

	# check order and format
	for i: int in header_line.size():
		var header: String = header_line[i]
		header = header.to_lower()
		header = header.strip_edges()
		if header != headers.list[i].to_lower():
			push_error("error csv header wrong format. expecetd %s but found %s" % [headers.list[i], header])
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
		if line.size() > headers.size or line.size() == 0:
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


func save_csv(path: String, csv: Array[PackedStringArray], append: bool = false) -> void:
	path = ResUtil.SAVE_STATES_PATH + path
	# make sure path is lower case
	path = path.to_lower()
	# print("saving json %s..." % path)

	# create directory, if not exist yet
	var dir_path: String = path.get_base_dir()
	var dir: DirAccess = DirAccess.open(ResUtil.USER_PATH)
	if not dir.dir_exists(dir_path):
		print("dir %s not found, creating now..." % dir_path)
		var err_dir: Error = dir.make_dir_recursive(dir_path)
		if err_dir != OK:
			push_error("error while creating directory %s; error with code %d" % [dir_path, err_dir])
			return
	var file: FileAccess

	if append:
		# READ_WRITE is needed to append
		if COMPRESSION_ON:
			file = FileAccess.open_compressed(path, FileAccess.READ_WRITE, COMPRESSION_MODE)
		else:
			file = FileAccess.open(path, FileAccess.READ_WRITE)

	if file == null:
		if COMPRESSION_ON:
			file = FileAccess.open_compressed(path, FileAccess.WRITE, COMPRESSION_MODE)
		else:
			file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("error while opening file: file is null")
		return

	# check for file errors
	var err: int = file.get_error()
	if err != OK:
		push_error("error while opening file: error with code %d" % err)
		return

	# go to end of file to append
	if append:
		file.seek_end()

	# save to file
	for line: PackedStringArray in csv:
		file.store_csv_line(line)
	
	file.close()

	# check again for file errors
	err = file.get_error()
	if err != OK:
		print("again opening file error with code %d" % err)
		print(err)
		return

	backup_util.create(path)


func read_csv(path: String, after_backup: bool = false) -> Array[PackedStringArray]:
	# make sure path is lower case
	path = path.to_lower()

	# open file
	var file: FileAccess
	if COMPRESSION_ON:
		file = FileAccess.open_compressed(path, FileAccess.READ, FileAccess.COMPRESSION_GZIP)
	else:
		file = FileAccess.open(path, FileAccess.READ)

	# check errors
	var err: int = FileAccess.get_open_error()
	if err != OK:
		if after_backup:
			print("opening file %s error with code %d" % [path, err])
			return []
		else:
			print("opening file %s error with code %d, restoring backup..." % [path, err])
			var backup_result: bool = backup_util.restore(path)
			if backup_result:
				return read_csv(path, true)
			else:
				print("error while restoring backup")
				return []

	var csv: Array[PackedStringArray] = []
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() > 0:
			csv.append(line)

	file.close()
	return csv


func _array_to_csv_list(array: Array[StringName]) -> String:
	if array == null or array.size() == 0:
		return ""
	var string: StringName = ", ".join(array)
	return "\"%s\"" % string


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
		# slash
		if unicode_char == 47:
			return true

		var valid_letter: bool = text_server.is_valid_letter(unicode_char)
		var valid_number: bool = string[i].is_valid_float()

		if not valid_letter and not valid_number:
			print("csv line not vaild: %s" % string)
			print("not allowed unicode sign: %s code: %d" % [char(unicode_char), unicode_char])
			return false

	return true


func _get_string_or_default(line: PackedStringArray, index: int) -> String:
	if index < 0:
		return ""
	if index >= line.size():
		return ""
	return line[index]


func _get_int_or_default(line: PackedStringArray, index: int) -> int:
	if index < 0:
		return 0
	if index >= line.size():
		return 0
	return int(line[index])

