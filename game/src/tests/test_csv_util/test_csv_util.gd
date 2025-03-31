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

	print("converting csv to world...")
	var world_from_csv: World = csv_util.csv_to_world(world_csv)
	print("converting world to csv done.")

	print("converting players to csv...")
	var players_csv: Array[PackedStringArray] = csv_util.players_to_csv(world)
	csv_util.save_csv("players.csv", players_csv)
	print("converting players to csv done.")

	print("converting csv to players...")
	csv_util.csv_to_players(players_csv, world_from_csv)
	print("converting csv to players done.")


	print("compare world with world from csv...")
	assert(world.continents.size() == world_from_csv.continents.size())
	assert(world.get_all_nations().size() == world_from_csv.get_all_nations().size())
	assert(world.get_all_leagues().size() == world_from_csv.get_all_leagues().size())
	var all_teams: Array[Team] = world.get_all_teams()
	var csv_all_teams: Array[Team] = world_from_csv.get_all_teams()
	assert(all_teams.size() == csv_all_teams.size())

	for i: int in all_teams.size():
		var team: Team = all_teams[i]
		var csv_team: Team = csv_all_teams[i]
		assert(team.name == csv_team.name)
		assert(team.finances.balance[-1] == csv_team.finances.balance[-1])
		assert(team.stadium.name == csv_team.stadium.name)
		assert(team.stadium.capacity == csv_team.stadium.capacity)

		assert(team.players.size() == csv_team.players.size())
		for j: int in team.players.size():
			var player: Player = team.players[j]
			var csv_player: Player = csv_team.players[j]
			assert(player.name == csv_player.name)
			assert(player.surname == csv_player.surname)
			# TODO: add missing fields
	print("compare world with world from csv done.")

	print("test: save world done.")


