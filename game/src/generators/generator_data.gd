# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later
class_name GeneratorData

const NAMES_DIR: String = "res://data/player_names/"
const WORLD_JSON_PATH: String = "res://data/world/world.json"


# [country_code][]
var male_names: Dictionary[String, Array] = {}
var female_names: Dictionary[String, Array] = {}
var surnames: Dictionary[String, Array] = {}

var names: Dictionary = {}


func load_data() -> World:
	var world: World = _load_world()
	_load_person_names(world)
	breakpoint
	return world


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
			locale.code = locale_dict.iso_639_1
			nation.locales.append(locale)

		# borders
		for border: String in nation_dict.borders:
			nation.borders.append(border)

		continent.nations.append(nation)

	return world


func _load_person_names(world: World) -> void:
	for nation: Nation in world.get_all_nations():
		for locale: Locale in nation.locales:
			var code: String = locale.code + "_" + nation.code.to_upper()
			var names_file: FileAccess = FileAccess.open(
				NAMES_DIR + code + ".json", FileAccess.READ
			)
			# check first if file exists
			if names_file:
				# print("names file found: " + code)
				names[code] = {}
				var names2: Dictionary = JSON.parse_string(names_file.get_as_text())
				names[code] = names2
			# else:
				# print("names file not found: " + code)


