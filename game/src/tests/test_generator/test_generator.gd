# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestGenerator
extends Test


func test() -> void:
	print("test: generator...")
	RngUtil.reset_seed("TestSeed", 0)

	var generator: Generator = Generator.new()
	# generate world
	var world: World = generator.generate_world()

	assert(world.continents.size() > 0)

	# generate players
	generator.generate_players(world)

	print("test: required properties...")

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					assert(team.players.size() > Const.LINEUP_PLAYERS_AMOUNT)
					assert(team.get_goalkeeper() != null)
	print("test: required properties done.")

	print("test: deterministic...")
	# test deterministic generations x time
	for i: int in range(2):
		print("test: deterministic run " + str(i + 1))

		RngUtil.reset_seed("TestSeed", 0)

		var test_world: World = generator.generate_world()
		# generate players
		generator.generate_players(test_world)

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

	print("test: deterministic done.")

	print("test: generator done.")
