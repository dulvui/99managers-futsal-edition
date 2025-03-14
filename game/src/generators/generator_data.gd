# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later
class_name GeneratorData

const NAMES_DIR: String = "res://data/player_names/"
const WORLD_JSON_PATH: String = "res://data/world/world.json"


# [country_code][]
# var male_names: Dictionary[String, Array] = {}
# var female_names: Dictionary[String, Array] = {}
# var surnames: Dictionary[String, Array] = {}

var names: Dictionary = {}


func load_data() -> World:
	var world: World = _load_world()
	_load_person_names(world)
	return world


func get_random_name(nation: Nation) -> String:
	# TODO pick weighted random locale
	# firt much more probable than second
	var locale: Locale = nation.locales[0]
	var code: String = locale.code + "_" + nation.code.to_upper()

	# check if names exist for nation, if not, pick random
	# TODO search in borders
	if not names.has(code):
		code = RngUtil.pick_random(names.keys())

	# male
	if Global.generation_player_names == Enum.PlayerNames.MALE:
		var size: int = (names[code]["first_names_male"] as Array).size()
		return names[code]["first_names_male"][RngUtil.rng.randi() % size]
	# female
	elif Global.generation_player_names == Enum.PlayerNames.FEMALE:
		var size: int = (names[code]["first_names_female"] as Array).size()
		return names[code]["first_names_female"][RngUtil.rng.randi() % size]

	# mixed
	var size_female: int = (names[code]["first_names_female"] as Array).size()
	var size_male: int = (names[code]["first_names_male"] as Array).size()
	var female_names: Array = names[code]["first_names_female"]
	var male_names: Array = names[code]["first_names_male"]

	var mixed_names: Array = []
	mixed_names.append_array(female_names)
	mixed_names.append_array(male_names)

	return mixed_names[RngUtil.rng.randi() % (size_female + size_male)]


func get_random_surnname(nation: Nation) -> String:
	# TODO pick weighted random locale
	# firt much more probable than second
	var locale: Locale = nation.locales[0]
	var code: String = locale.code + "_" + nation.code.to_upper()

	# TODO bigger proability for border nations (needs data)
	# 10% change of having random nation's surname
	var different_nation_factor: int = RngUtil.rng.randi() % 100
	if different_nation_factor > 90:
		code = RngUtil.pick_random(names.keys())

	# check if names exist for nation, if not, pick random
	if not names.has(code):
		code = RngUtil.pick_random(names.keys())

	var size: int = (names[code]["last_names"] as Array).size()
	return names[code]["last_names"][RngUtil.rng.randi() % size]



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
				names[code] = JSON.parse_string(names_file.get_as_text())
