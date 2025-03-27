# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVUtil


var line_index: int
var headers: PackedStringArray

var built_in_headers: PackedStringArray
var array_headers: PackedStringArray
var resource_headers: PackedStringArray


func world_to_csv(world: World) -> Array[PackedStringArray]:
	var world_lines: Array[PackedStringArray] = []
	var players_lines: Array[PackedStringArray] = []

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					var team_line: PackedStringArray = PackedStringArray()
					team_line.append(continent.code)
					team_line.append(nation.code)
					team_line.append(league.name)
					team_line.append(str(league.id))
					
					get_headers(team)
					team_line.append_array(res_to_line(team))

					world_lines.append(team_line)

					for player: Player in team.players:
						var player_line: PackedStringArray = PackedStringArray()
						player_line.append(str(team.id))
					
						get_headers(player)
						player_line.append_array(res_to_line(player))

						# attributes
						get_headers(player.attributes.mental)
						player_line.append_array(res_to_line(player.attributes.mental))
						get_headers(player.attributes.physical)
						player_line.append_array(res_to_line(player.attributes.physical))
						get_headers(player.attributes.technical)
						player_line.append_array(res_to_line(player.attributes.technical))
						get_headers(player.attributes.goalkeeper)
						player_line.append_array(res_to_line(player.attributes.goalkeeper))

						players_lines.append(player_line)

	# var world_csv: Array[PackedStringArray] = []
	# # world_csv.append(world_headers)
	# world_csv.append_array(world_lines)
	# _save_csv(path + "world.csv", world_csv)

	var players_csv: Array[PackedStringArray] = []
	# players_csv.append(players_headers)
	players_csv.append_array(players_lines)
	# _save_csv(path + "players.csv", players_csv)

	return players_csv


func get_headers(resource: Resource) -> PackedStringArray:
	line_index = 0
	headers = PackedStringArray()

	built_in_headers = PackedStringArray()
	array_headers = PackedStringArray()
	resource_headers = PackedStringArray()

	# only add export vars to dictionary
	var property_list: Array[Dictionary] = resource.get_property_list()
	for property: Dictionary in property_list:
		# only convert properties with @export annotation
		# enums have own flag
		if (
			property.usage != Const.CUSTOM_PROPERTY_EXPORT
			and property.usage != Const.CUSTOM_PROPERTY_EXPORT_ENUM
		):
			continue

		var property_name: String = property.name
		
		var value: Variant = resource.get(property_name)

		if value is Array:
			array_headers.append(property_name)

		elif value is JSONResource:
			resource_headers.append(property_name)

		elif value is Dictionary:
			# push_warning("csv util found dict with name %s " % property_name)
			continue
		else:
			built_in_headers.append(property_name)

	headers.append_array(built_in_headers)
	headers.append_array(resource_headers)
	headers.append_array(array_headers)
	
	return headers


# use result, since on next call array will be reused for performance
func res_to_line(resource: Resource) -> PackedStringArray:
	# line.clear()
	var line: PackedStringArray = PackedStringArray()

	for header: String in built_in_headers:
		var value: String = str(resource.get(header))
		line.append(value)

	# for header: String in resource_headers:
	# 	var value: JSONResource = get(header)
	# 	line.append_array(res_to_line(value))

	return line



func res_array_to_csv(array: Array[Resource]) -> Array[PackedStringArray]:
	if array.size() == 0:
		return []

	var csv: Array[PackedStringArray] = []
	for resource: Resource in array:
		csv.append(res_to_line(resource))
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
		file = FileAccess.open(path, FileAccess.READ_WRITE)

	if file == null:
		file = FileAccess.open(path, FileAccess.WRITE, )

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
