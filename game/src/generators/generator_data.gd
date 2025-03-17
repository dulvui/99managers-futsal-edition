# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorData

const NAMES_DIR: StringName = "res://data/player_names/"
const WORLD_JSON_PATH: StringName = "res://data/world/world.json"

const FEMALE_NAMES: StringName = "female_names"
const MALE_NAMES: StringName = "male_names"
const SURNAMES: StringName = "surnames"

var names: Dictionary = {}


func load_data() -> World:
	var world: World = _load_world()
	_load_person_names(world)
	return world


func get_random_name(nation: Nation) -> String:
	# TODO pick weighted random locale
	# firt much more probable than second
	var locale: Locale = nation.locales[0]
	var code: String = locale.code

	# check if names exist for nation, if not, pick random
	# TODO search in border nations
	if not names.has(code):
		code = RngUtil.pick_random(names.keys())

	# male
	if Global.generation_player_names == Enum.PlayerNames.MALE:
		var size: int = (names[code][MALE_NAMES] as Array).size()
		return names[code][MALE_NAMES][RngUtil.rng.randi() % size]
	# female
	elif Global.generation_player_names == Enum.PlayerNames.FEMALE:
		var size: int = (names[code][FEMALE_NAMES] as Array).size()
		return names[code][FEMALE_NAMES][RngUtil.rng.randi() % size]

	# mixed
	var size_female: int = (names[code][FEMALE_NAMES] as Array).size()
	var size_male: int = (names[code][MALE_NAMES] as Array).size()
	var female_names: Array = names[code][FEMALE_NAMES]
	var male_names: Array = names[code][MALE_NAMES]

	var mixed_names: Array = []
	mixed_names.append_array(female_names)
	mixed_names.append_array(male_names)

	return mixed_names[RngUtil.rng.randi() % (size_female + size_male)]


func get_random_surnname(nation: Nation) -> String:
	# TODO pick weighted random locale
	# firt much more probable than second
	var locale: Locale = nation.locales[0]
	var code: String = locale.code

	# TODO bigger proability for border nations (needs data)
	# 10% change of having random nation's surname
	var different_nation_factor: int = RngUtil.rng.randi() % 100
	if different_nation_factor > 90:
		code = RngUtil.pick_random(names.keys())

	# check if names exist for nation, if not, pick random
	if not names.has(code):
		code = RngUtil.pick_random(names.keys())

	var size: int = (names[code][SURNAMES] as Array).size()
	return names[code][SURNAMES][RngUtil.rng.randi() % size]



func _load_world() -> World:
	var world: World = World.new()

	var world_file: FileAccess = FileAccess.open(WORLD_JSON_PATH, FileAccess.READ)
	var world_dict: Array = JSON.parse_string(world_file.get_as_text())

	for nation_dict: Dictionary in world_dict:
		# continent
		var continent: Continent
		var continent_name: String = nation_dict.continent
		var continents: Array[Continent] = world.continents.filter(func(c: Continent) -> bool: return c.name == continent_name)
		if continents.size() == 0:
			continent = Continent.new()
			continent.name = continent_name
			world.continents.append(continent)
		else:
			continent = continents[0]

		# nation
		var nation: Nation = Nation.new()
		nation.name = nation_dict.name
		nation.code = nation_dict.code
		
		# locales
		for locale_dict: Dictionary in nation_dict.languages:
			var locale: Locale = Locale.new()
			locale.name = locale_dict.name
			locale.code = locale_dict.code
			nation.locales.append(locale)

		# borders
		for border: String in nation_dict.borders:
			nation.borders.append(border)

		continent.nations.append(nation)

	return world


func _load_person_names(world: World) -> void:
	for nation: Nation in world.get_all_nations():
		for locale: Locale in nation.locales:
			var female_names_file: String = locale.code + FEMALE_NAMES + ".csv"
			var male_names_file: String = locale.code + MALE_NAMES + ".csv"
			var surname_file: String = locale.code + SURNAMES + ".csv"

			var female_names: Array[StringName] = _read_name_csv_file(female_names_file)
			if female_names.size() > 0:
				names[locale][FEMALE_NAMES] = female_names

			var male_names: Array[StringName] = _read_name_csv_file(male_names_file)
			if male_names.size() > 0:
				names[locale][MALE_NAMES] = male_names

			var surnames: Array[StringName] = _read_name_csv_file(surname_file)
			if surnames.size() > 0:
				names[locale][SURNAMES] = surnames


func _read_name_csv_file(path: StringName) -> Array[StringName]:
	var names_in_csv: Array[StringName] = []
	if not FileAccess.file_exists(path):
		return []

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var error: Error = file.get_error()
	if error != OK:
		print("error while opening name csv file " + path)
		return []
	
	while not file.eof_reached():
		# get_csv_line not needed for now, since every name has it's own line
		var line: String = file.get_line()

		error = file.get_error()
		if error == Error.ERR_FILE_EOF:
			break

		# check for reading errors
		if error != OK:
			Global.error_load_world = 2
			print("error while reading lines from name csv file %s with code %d" % [path, error])
			# returning what found so far
			return names_in_csv
		
		# skip lines starting with #, they are comments like source url's
		if "#" in line:
			continue

		names_in_csv.append(line)
	
	return names_in_csv

