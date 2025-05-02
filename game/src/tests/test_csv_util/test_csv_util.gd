# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestCSVUtil
extends Test


func test() -> void:
	print("test: csv util...")
	test_save_world()
	print("test: csv util done.")


func test_save_world() -> void:
	print("test: save world...")

	Global.start_date = Time.get_date_dict_from_system()

	# create world
	print("generating world...")
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new("TestSeed", Enum.PlayerNames.MIXED)
	var success: bool = generator.initialize_world(world)
	assert(success)
	print("generating world done...")
	
	var csv_util: CSVUtil = CSVUtil.new()

	print("converting players to csv...")
	var csv: Array[PackedStringArray] = csv_util.players_to_csv(world)
	print("converting players to csv done.")

	print("converting csv to players...")
	csv_util.csv_to_players(csv, world)
	print("converting csv to players done.")

	print("validate world...")
	# TODO: validate world
	print("validate world done.")

	print("test: save world done.")


