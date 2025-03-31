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
	RngUtil.reset_seed("TestSeed", 0)

	# create world
	print("generating world...")
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new()
	var success: bool = generator.generate_teams(world)
	assert(success)
	print("generating world done...")
	
	var csv_util: CSVUtil = CSVUtil.new()
	print("converting world to csv...")
	var world_csv: Array[PackedStringArray] = csv_util.world_to_csv(world)
	csv_util.save_csv("world.csv", world_csv)
	print("converting world to csv done.")

	print("converting players to csv...")
	var players_csv: Array[PackedStringArray] = csv_util.players_to_csv(world)
	csv_util.save_csv("players.csv", players_csv)
	print("converting world to csv done.")

	print("test: save world done.")


