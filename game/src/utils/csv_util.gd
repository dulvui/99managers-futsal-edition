# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVUtil


var line_index: int
var headers: PackedStringArray

var built_in_headers: PackedStringArray
var array_headers: PackedStringArray
var resource_headers: PackedStringArray


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
	# 	line.append(value)

	return line



func res_array_to_csv(array: Array[Resource]) -> Array[PackedStringArray]:
	if array.size() == 0:
		return []

	var csv: Array[PackedStringArray] = []
	for resource: Resource in array:
		csv.append(res_to_line(resource))
	return csv


func save_world(save_state: SaveState, world: World) -> void:
	var csv_dir: String = save_state.id + "/csv/"
	var csv_util: CSVResourceUtil = CSVResourceUtil.new()

	var world_csv: Array[PackedStringArray] = []
	var players_csv: Array[PackedStringArray] = []
	
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					var team_line: PackedStringArray = []
					team_line.append(continent.code)
					team_line.append(nation.code)
					team_line.append(league.name)
					team_line.append(str(league.id))
					
					csv_util.get_headers(team)
					team_line.append_array(csv_util.res_to_line(team))

					world_csv.append(team_line)

					for player: Player in team.players:
						var player_line: PackedStringArray = []
						player_line.append(str(team.id))
					
						csv_util.get_headers(player)
						player_line.append_array(csv_util.res_to_line(player))

						players_csv.append(player_line)


	_save_csv(csv_dir + "world.csv", world_csv)
	_save_csv(csv_dir + "players.csv", players_csv)


func _save_csv(path: String, csv: Array[PackedStringArray]) -> void:
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

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("error while opening file: file is null")
		breakpoint
		return

	# check for file errors
	var err: int = file.get_error()
	if err != OK:
		push_error("error while opening file: error with code %d" % err)
		return

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
