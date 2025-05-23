# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorNames

const NAMES_DIR: StringName = "res://data/player_names/"

const FEMALE_NAMES: StringName = "female_names"
const MALE_NAMES: StringName = "male_names"
const SURNAMES: StringName = "surnames"

var player_names: Enum.PlayerNames
var names: Dictionary = {}
var rng_util: RngUtil


func _init(world: World, p_player_names: Enum.PlayerNames, p_rng_util: RngUtil) -> void:
	player_names = p_player_names
	rng_util = p_rng_util

	for nation: Nation in world.get_all_nations():
		for locale: Locale in nation.locales:
			var code: String = locale.code

			var female_names_file: String = NAMES_DIR + code + "_" + FEMALE_NAMES + ".csv"
			var male_names_file: String = NAMES_DIR + code + "_" + MALE_NAMES + ".csv"
			var surname_file: String = NAMES_DIR + code + "_" + SURNAMES + ".csv"

			var female_names: Array[String] = _read_name_csv_file(female_names_file)
			if female_names.size() > 0:
				if not code in names.keys():
					names[code] = {}
				names[code][FEMALE_NAMES] = female_names

			var male_names: Array[String] = _read_name_csv_file(male_names_file)
			if male_names.size() > 0:
				if not code in names.keys():
					names[code] = {}
				names[code][MALE_NAMES] = male_names

			var surnames: Array[String] = _read_name_csv_file(surname_file)
			if surnames.size() > 0:
				if not code in names.keys():
					names[code] = {}
				names[code][SURNAMES] = surnames


func get_random_name(nation: Nation) -> String:
	# TODO pick weighted random locale
	# firt much more probable than second
	var locale: Locale = nation.locales[0]
	var code: String = locale.code

	# check if names exist for nation, if not, pick random
	# TODO search in border nations
	if not names.has(code):
		code = rng_util.pick_random(names.keys())

	# # male
	# if player_names == Enum.PlayerNames.MALE:
	# 	var names_array: Array[String] = names[code][MALE_NAMES]
	# 	return rng_util.pick_random(names_array)
	# # female
	# elif player_names == Enum.PlayerNames.FEMALE:
	# 	var names_array: Array[String] = names[code][FEMALE_NAMES]
	# 	return rng_util.pick_random(names_array)

	# mixed
	var female_names: Array = names[code][FEMALE_NAMES]
	var male_names: Array = names[code][MALE_NAMES]
	var mixed_names: Array = []
	mixed_names.append_array(female_names)
	mixed_names.append_array(male_names)

	return rng_util.pick_random(mixed_names)


func get_random_surnname(nation: Nation) -> String:
	# TODO pick weighted random locale
	# firt much more probable than second
	var locale: Locale = nation.locales[0]
	var code: String = locale.code

	# TODO bigger proability for border nations (needs data)
	# 10% change of having random nation's surname
	var different_nation_factor: int = rng_util.randi() % 100
	if different_nation_factor > 90:
		code = rng_util.pick_random(names.keys())

	# check if names exist for nation, if not, pick random
	if not code in names.keys() or not SURNAMES in names[code]:
		code = rng_util.pick_random(names.keys())

	var names_array: Array[String] = names[code][SURNAMES]
	return rng_util.pick_random(names_array)


func _read_name_csv_file(path: String) -> Array[String]:
	var names_in_csv: Array[String] = []
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
			print("error while reading lines from name csv file %s with code %d" % [path, error])
			# returning what found so far
			return names_in_csv

		# skip lines starting with #, they are comments like source url's
		if "#" in line:
			continue

		names_in_csv.append(line)

	return names_in_csv

