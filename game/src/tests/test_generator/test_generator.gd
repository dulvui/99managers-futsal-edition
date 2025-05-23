# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestGenerator
extends Test


const TEST_WORLD_CSV_WITH_ERRORS: String = "res://data/world/test-data-with-errors.csv"


func test() -> void:
	print("test: generator...")
	Global.reset_data()
	test_required_properties()

	Global.reset_data()
	test_determenistic_generation()

	Global.reset_data()
	test_history()
	print("test: generator done.")


func test_required_properties() -> void:
	Global.start_date = Time.get_date_dict_from_system()

	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate players
	var generator: Generator = Generator.new("TestSeed", Enum.PlayerNames.MIXED)
	var success: bool = generator.initialize_world(world)
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

	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new("TestSeed", Enum.PlayerNames.MIXED)
	var success: bool = generator.initialize_world(world)
	assert(success)

	# test deterministic generations x time
	for i: int in range(3):
		print("test: deterministic run " + str(i + 1))

		# create test_world
		var test_world_generator: GeneratorWorld = GeneratorWorld.new()
		var test_world: World = test_world_generator.init_world()

		# generate teams
		var test_generator: Generator = Generator.new("TestSeed", Enum.PlayerNames.MIXED)
		var test_success: bool = test_generator.initialize_world(test_world)

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

						for o: int in team.players.size():
							var player: Player = team.players[o]
							var test_player: Player = test_team.players[o]

							# player ids
							assert(player.id == test_player.id)
							assert(player.team_id == test_player.team_id)
							assert(player.league_id == test_player.league_id)

							# player attributes
							assert(player.attributes.physical.pace == test_player.attributes.physical.pace)
							assert(player.attributes.technical.shooting == test_player.attributes.technical.shooting)
							assert(player.attributes.mental.aggression == test_player.attributes.mental.aggression)
							assert(player.attributes.goalkeeper.reflexes == test_player.attributes.goalkeeper.reflexes)

							# player colors
							assert(player.haircolor == test_player.haircolor)
							assert(player.skintone == test_player.skintone)
							assert(player.eyecolor == test_player.eyecolor)

							# player names
							var test_player_name: String = test_player.get_full_name()
							var player_name: String = player.get_full_name()
							assert(player_name == test_player_name)


	print("test: deterministic generation done.")


func test_history() -> void:
	print("test: history...")

	Global.start_date = Time.get_date_dict_from_system()

	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()

	# generate teams
	var generator: Generator = Generator.new("TestSeed", Enum.PlayerNames.MIXED)
	generator.initialize_global_values(world)
	var csv: Array[PackedStringArray] = generator.get_world_csv()
	var result: bool = generator.initialize_teams(world, csv)
	assert(result)

	# save team names/id by league
	var team_names: Dictionary[String, Array] = {}
	var team_ids: Dictionary[String, Array] = {}
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					# save names
					if not team_names.has(league.name):
						team_names[league.name] = []
					team_names[league.name].append(team.name)
					# save ids
					if not team_ids.has(league.name):
						team_ids[league.name] = []
					team_ids[league.name].append(team.id)

	# generate club history
	var generator_history: GeneratorHistory = GeneratorHistory.new(RngUtil.new())
	generator_history.generate_club_history(world)

	# check history table, playoffs and playouts
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				assert(league.history_tables.size() == GeneratorHistory.HISTORY_YEARS)
				if league.playoff_teams > 0:
					assert(league.history_playoffs.size() == GeneratorHistory.HISTORY_YEARS)
				if league.playout_teams > 0:
					assert(league.history_playouts.size() == GeneratorHistory.HISTORY_YEARS)

	# check that teams are still in correct league, as defined in csv
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				# check teams
				for team: Team in league.teams:
					# print("%s - %s" % [league.name, team.name])
					assert(team.name in team_names[league.name])
					assert(team.name in team_names[league.name])
					assert(team.id in team_ids[league.name])
					assert(team.league_id == league.id)
				# check table
				for value: TableValue in league.table.teams:
					assert(value.team.name in team_names[league.name])
					assert(value.team.id in team_ids[league.name])
					assert(value.team.league_id == league.id)

	# TODO test player history
	# history.generate_player_history(world)

	print("test: history done.")


func test_errors_and_warnings() -> void:
	print("test: errors and warnings...")

	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	# generate teams
	var generator: Generator = Generator.new("TestSeed", Enum.PlayerNames.MIXED)
	var success: bool = generator.initialize_world(world, TEST_WORLD_CSV_WITH_ERRORS)
	assert(not success)

	# TODO check exact error amount
	assert(Global.generation_errors.size() > 0)
	assert(Global.generation_warnings.size() > 0)

	print("test: errors and warnings done.")

