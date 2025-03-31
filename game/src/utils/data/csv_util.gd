# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVUtil

const COMPRESSION_ON: bool = false
const COMPRESSION_MODE: FileAccess.CompressionMode = FileAccess.CompressionMode.COMPRESSION_GZIP

var built_in_headers: PackedStringArray
var array_headers: PackedStringArray
var resource_headers: PackedStringArray


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
					if team.finances.balance.size() > 1:
						team_line.append(str(team.finances.balance[-1]))
					else:
						team_line.append("-1")
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
						player_line.append(team.name)
						player_line.append(str(team.id))
						
						# based on CSVHeaders.PLAYER
						# "name",
						# "surname",
						# "birth_date",
						# "nationality",
						# "shirt number",
						# "preferred foot",
						# "main position",
						# "alt positions",
						# "injury prone",
						# "eye color",
						# "hair color",
						# "skintone color",
						player_line.append(player.name)
						player_line.append(player.surname)
						player_line.append(FormatUtil.day(player.birth_date))
						player_line.append(player.nation)
						player_line.append(str(player.nr))
						player_line.append(Enum.get_foot_text(player))
						player_line.append(player.position.get_type_text())
						var alt_positions: Array[StringName] = []
						for position: Position in player.alt_positions:
							alt_positions.append(position.get_type_text())
						player_line.append(_array_to_csv_list(alt_positions))
						player_line.append(str(player.injury_factor))
						player_line.append(player.eyecolor)
						player_line.append(player.haircolor)
						player_line.append(player.skintone)


						# attributes
						player_line.append_array(res_to_line(player.attributes.goalkeeper, CSVHeaders.PLAYER_ATTRIBUTES_GOALKEEPER))
						player_line.append_array(res_to_line(player.attributes.mental, CSVHeaders.PLAYER_ATTRIBUTES_MENTAL))
						player_line.append_array(res_to_line(player.attributes.physical, CSVHeaders.PLAYER_ATTRIBUTES_PHYSICAL))
						player_line.append_array(res_to_line(player.attributes.technical, CSVHeaders.PLAYER_ATTRIBUTES_TECHNICAL))

						lines.append(player_line)

	var headers: PackedStringArray = []
	# add headers
	headers.append("team name")
	headers.append("team id")
	headers.append_array(CSVHeaders.PLAYER)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_GOALKEEPER)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_MENTAL)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_PHYSICAL)
	headers.append_array(CSVHeaders.PLAYER_ATTRIBUTES_TECHNICAL)

	var csv: Array[PackedStringArray] = []
	csv.append(headers)
	csv.append_array(lines)

	return csv


# use result, since on next call array will be reused for performance
func res_to_line(resource: Resource, headers: PackedStringArray) -> PackedStringArray:
	# line.clear()
	var line: PackedStringArray = PackedStringArray()

	for header: String in headers:
		var value: Variant = resource.get(header)
		if value == null:
			line.append("")
		else:
			line.append(str(value))

	# for header: String in resource_headers:
	# 	var value: JSONResource = get(header)
	# 	line.append_array(res_to_line(value))

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


func _array_to_csv_list(array: Array[StringName]) -> String:
	if array == null or array.size() == 0:
		return ""
	var string: StringName = ", ".join(array)
	return "\"%s\"" % string

