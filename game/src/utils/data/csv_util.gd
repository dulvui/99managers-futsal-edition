# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVUtil

const COMPRESSION_ON: bool = false
const COMPRESSION_MODE: FileAccess.CompressionMode = FileAccess.CompressionMode.COMPRESSION_GZIP

var built_in_headers: PackedStringArray
var array_headers: PackedStringArray
var resource_headers: PackedStringArray

var backup_util: BackupUtil


func _init() -> void:
	backup_util = BackupUtil.new()


func world_to_csv(world: World) -> Array[PackedStringArray]:
	var lines: Array[PackedStringArray] = []

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					var team_line: PackedStringArray = PackedStringArray()
					# using CSVHeaders.WORLD
					team_line.append(continent.code)
					team_line.append(nation.code)
					team_line.append(league.name)
					# team_line.append(str(league.id))

					# using CSVHeaders.TEAM
					team_line.append(team.name)
					if team.finances.balance.size() > 0:
						team_line.append(str(team.finances.balance[-1]))
					else:
						team_line.append("0")
					team_line.append(team.stadium.name)
					team_line.append(str(team.stadium.capacity))

					lines.append(team_line)

	var headers: PackedStringArray = []
	# add headers
	headers.append_array(CSVHeaders.WORLD)
	headers.append_array(CSVHeaders.TEAM)

	var csv: Array[PackedStringArray] = []
	csv.append(headers)
	csv.append_array(lines)

	return csv


func players_to_csv(world: World) -> Array[PackedStringArray]:
	var lines: Array[PackedStringArray] = []

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					for player: Player in team.players:
						var player_line: PackedStringArray = PackedStringArray()
						player_line.append(league.name)
						player_line.append(team.name)
						# player_line.append(str(team.id))
						
						# based on CSVHeaders.PLAYER
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
						player_line.append_array(res_to_line(player.attributes.goalkeeper, CSVHeaders.PLAYER_ATTRIBUTES_GOALKEEPER))
						player_line.append_array(res_to_line(player.attributes.mental, CSVHeaders.PLAYER_ATTRIBUTES_MENTAL))
						player_line.append_array(res_to_line(player.attributes.physical, CSVHeaders.PLAYER_ATTRIBUTES_PHYSICAL))
						player_line.append_array(res_to_line(player.attributes.technical, CSVHeaders.PLAYER_ATTRIBUTES_TECHNICAL))

						lines.append(player_line)

	var headers: PackedStringArray = []
	# add headers
	headers.append("league name")
	headers.append("team name")
	# headers.append("team id")
	headers.append_array(CSVHeaders.PLAYER)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_GOALKEEPER)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_MENTAL)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_PHYSICAL)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_TECHNICAL)

	var csv: Array[PackedStringArray] = []
	csv.append(headers)
	csv.append_array(lines)

	return csv


func csv_to_world(csv: Array[PackedStringArray]) -> World:
	var generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = generator.init_world()
	
	# remove headers
	csv.pop_front()


	# last values found in last line read
	# can be reused for next line, since lines most likely are grouped by team
	var continent: Continent = null
	var nation: Nation = null
	var league: League = null
	var team: Team = null

	var line_index: int = 0
	for line: PackedStringArray in csv:
		line_index += 1
		var continent_code: String = line[0]
		var nation_code: String = line[1]
		var league_name: String = line[2]
		var team_name: String = line[3]
		var team_balance: String = line[4]
		var stadium_name: String = line[5]
		var stadium_capacity: String = line[6]
	
		# continent
		if continent == null or continent.code != continent_code:
			continent = world.get_continent_by_code(continent_code)
		if continent == null:
			push_error("no continent with code %s found in line %d" % [continent_code, line_index])
			continue

		# nation
		if nation == null or nation.code != nation_code:
			nation = world.get_nation_by_code(nation_code, continent)
		if nation == null:
			push_error("no nation with code %s found in line %d" % [nation_code, line_index])
			continue

		# league
		if league == null or league.name != league_name:
			league = world.get_league_by_name(league_name, nation)
		if league == null:
			league = League.new()
			league.name = league_name
			league.pyramid_level = nation.leagues.size() + 1
			nation.leagues.append(league)

		# team
		if team == null or team.name != team_name:
			team = league.get_team_by_name(team_name)
		if team == null:
			team = Team.new()
			team.name = team_name
			team.finances.balance[-1] = int(team_balance)
			team.stadium = Stadium.new()
			team.stadium.name = stadium_name
			team.stadium.capacity = int(stadium_capacity)
			league.teams.append(team)

	return world


# adds players to teams in world
func csv_to_players(csv: Array[PackedStringArray], world: World) -> void:
	# last values found in last line read
	# can be reused for next line, since lines most likely are grouped by team
	var league: League = null
	var team: Team = null

	# remove header
	csv.pop_front()

	var column_size: int = 16
	column_size += CSVHeaders.PLAYER_ATTRIBUTES_GOALKEEPER.size()
	column_size += CSVHeaders.PLAYER_ATTRIBUTES_MENTAL.size()
	column_size += CSVHeaders.PLAYER_ATTRIBUTES_PHYSICAL.size()
	column_size += CSVHeaders.PLAYER_ATTRIBUTES_TECHNICAL.size()

	var line_index: int = 0
	for line: PackedStringArray in csv:
		line_index += 1
		if line.size() != column_size:
			continue

		var league_name: String = line[0]
		var team_name: String = line[1]
		var name: String = line[2]
		var surname: String = line[3]
		var value: String = line[4]
		var birth_date: String = line[5]
		var nationality: String = line[6]
		var nr: String = line[7]
		var foot_left: String = line[8]
		var foot_right: String = line[9]
		var position: String = line[10]
		var alt_positions: String = line[11]
		var injury_factor: String = line[12]
		var eyecolor: String = line[13]
		var haircolor: String = line[14]
		var skintone: String = line[15]
		# next values are attributes
		# attributes get set by iterating over attribute name arrays/headers
		var column_index: int = 16

		# league
		if league == null or league.name != league_name:
			league = world.get_league_by_name(league_name)
		if league == null:
			push_error("league not found with name %s in line %d" % [league_name, line_index])
			continue

		# team
		if team == null or team.name != team_name:
			team = league.get_team_by_name(team_name)
		if team == null:
			push_error("team not found with name %s in line %d" % [team_name, line_index])
			continue
		
		var player: Player = Player.new()
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
		# attributes
		for attribute: String in CSVHeaders.PLAYER_ATTRIBUTES_GOALKEEPER:
			player.attributes.goalkeeper.set(attribute, line[column_index])
			column_index += 1
		for attribute: String in CSVHeaders.PLAYER_ATTRIBUTES_MENTAL:
			player.attributes.mental.set(attribute, line[column_index])
			column_index += 1
		for attribute: String in CSVHeaders.PLAYER_ATTRIBUTES_PHYSICAL:
			player.attributes.physical.set(attribute, line[column_index])
			column_index += 1
		for attribute: String in CSVHeaders.PLAYER_ATTRIBUTES_TECHNICAL:
			player.attributes.technical.set(attribute, line[column_index])
			column_index += 1

		team.players.append(player)


# use result, since on next call array will be reused for performance
func res_to_line(resource: Resource, headers: PackedStringArray) -> PackedStringArray:
	var line: PackedStringArray = PackedStringArray()

	for header: String in headers:
		var value: Variant = resource.get(header)
		if value == null:
			line.append("")
		else:
			line.append(str(value))

	return line


func res_array_to_csv(array: Array[Resource], headers: PackedStringArray) -> Array[PackedStringArray]:
	if array.size() == 0:
		return []

	var csv: Array[PackedStringArray] = []
	for resource: Resource in array:
		csv.append(res_to_line(resource, headers))
	return csv


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
	path = ResUtil.SAVE_STATES_PATH + path
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

