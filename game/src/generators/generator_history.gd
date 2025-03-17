# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorHistory

# defines year, when history starts
const HISTORY_YEARS: int = 10


func generate_club_history(world: World) -> void:
	# TODO world cup history (once national teams exist)
	# TODO continental national teams cup

	var match_util: MatchUtil = MatchUtil.new(world)

	# calculate random results for x years
	for year: int in HISTORY_YEARS + 1:
		for contient: Continent in world.continents:
			for nation: Nation in contient.nations:
				for league: League in nation.leagues:
					# create match combinations
					var match_days: Array[Array] = match_util.create_combinations(
						league, league.teams
					)

					# generate random results for every match
					for match_day: Array in match_days:
						for matchz: Match in match_day:
							var home_goals: int = RngUtil.rng.randi_range(0, 10)
							var away_goals: int = RngUtil.rng.randi_range(0, 10)
							matchz.set_result(home_goals, away_goals, 0, 0, world)

		world.promote_and_delegate_teams()


func generate_player_history(_world: World) -> void:
	pass

