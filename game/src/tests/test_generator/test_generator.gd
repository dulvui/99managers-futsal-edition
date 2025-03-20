# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestGenerator
extends Test


const TEST_WORLD_CSV_WITH_ERRORS: String = "res://data/world/test_world_with_errors.csv"


func test() -> void:
	print("test: generator...")
	test_required_properties()
	test_determenistic_generation()
	test_history()
	print("test: generator done.")


func test_required_properties() -> void:
	Global.start_date = Time.get_date_dict_from_system()
	RngUtil.reset_seed("TestSeed", 0)

	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new()
	var success: bool = generator.generate_teams(world)
	assert(success)

	assert(world.continents.size() > 0)

	print("test: required properties...")

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			var pyramid_level_check: int = 1
			for league: League in nation.leagues:
				assert(league.pyramid_level == pyramid_level_check)
				pyramid_level_check += 1
				for team: Team in league.teams:
					assert(team.players.size() > Const.LINEUP_PLAYERS_AMOUNT)
					assert(team.get_goalkeeper() != null)
	print("test: required properties done.")


func test_determenistic_generation() -> void:
	print("test: deterministic generation...")

	Global.start_date = Time.get_date_dict_from_system()
	RngUtil.reset_seed("TestSeed", 0)

	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new()
	var success: bool = generator.generate_teams(world)
	assert(success)

	# test deterministic generations x time
	for i: int in range(2):
		print("test: deterministic run " + str(i + 1))

		RngUtil.reset_seed("TestSeed", 0)

		# create test_world
		var test_world_generator: GeneratorWorld = GeneratorWorld.new()
		var test_world: World = test_world_generator.init_world()
		# generate teams
		var test_generator: Generator = Generator.new()
		var test_success: bool = test_generator.generate_teams(test_world)
		assert(test_success)

		# continents
		assert(test_world.continents.size() == world.continents.size())

		# nations
		for j: int in world.continents.size():
			var continent: Continent = world.continents[j]
			var nations_size: int = continent.nations.size()

			var test_continent: Continent = test_world.continents[j]
			var test_nations_size: int = test_continent.nations.size()

			assert(nations_size == test_nations_size)

			# leagues
			for k: int in continent.nations.size():
				var nation: Nation = continent.nations[k]
				var leagues_size: int = nation.leagues.size()

				var test_nation: Nation = test_continent.nations[k]
				var test_leagues_size: int = test_nation.leagues.size()

				assert(leagues_size == test_leagues_size)

				# league teams
				for l: int in nation.leagues.size():
					var league: League = nation.leagues[l]
					var teams_size: int = league.teams.size()

					var test_league: League = test_nation.leagues[l]
					var test_teams_size: int = test_league.teams.size()

					assert(teams_size == test_teams_size)

					# team players
					for m: int in league.teams.size():
						var team: Team = league.teams[m]
						var player_size: int = team.players.size()

						var test_team: Team = test_league.teams[m]
						var test_player_size: int = test_team.players.size()

						assert(player_size == test_player_size)

						# player names
						for o: int in team.players.size():
							var player: Player = team.players[o]
							var player_name: String = player.get_full_name()

							var test_player: Player = test_team.players[o]
							var test_player_name: String = test_player.get_full_name()

							assert(player_name == test_player_name)
	print("test: deterministic generation done.")


func test_history() -> void:
	print("test: history...")

	Global.start_date = Time.get_date_dict_from_system()
	RngUtil.reset_seed("TestSeed", 0)

	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new()
	var success: bool = generator.generate_teams(world)
	assert(success)

	# make sure leagues have still same size after history generation
	var league_sizes: Dictionary[String, int] = {}
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				league_sizes[league.name] = league.teams.size()

	# history
	var history: GeneratorHistory = GeneratorHistory.new()
	# first generate clubs history with promotions, delegations, cup wins
	history.generate_club_history(world)

	# check league team sizes
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				assert(league_sizes[league.name] == league.teams.size())
	
	# TODO test player history
	# history.generate_player_history(world)

	print("test: history done.")


func test_errors_and_warnings() -> void:
	print("test: errors and  warnings...")

	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new()
	var success: bool = generator.generate_teams(world, TEST_WORLD_CSV_WITH_ERRORS)
	assert(not success)

	# TODO check exact error amount
	assert(Global.generation_errors.size() > 0)
	assert(Global.generation_warnings.size() > 0)

	print("test: errors and  warnings done.")
