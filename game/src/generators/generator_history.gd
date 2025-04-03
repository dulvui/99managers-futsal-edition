# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorHistory

# defines year, when history starts
const HISTORY_YEARS: int = 5


func generate_club_history(world: World = Global.world) -> void:
	# TODO world cup history (once national teams exist)
	# TODO continental national teams cup
	var match_util: MatchUtil = MatchUtil.new(world)
	var match_engine: MatchEngine = MatchEngine.new()

	# calculate random results for x years
	for year: int in HISTORY_YEARS - 1:
		for continent: Continent in world.continents:
			for nation: Nation in continent.nations:
				for league: League in nation.leagues:
					# create match combinations
					var match_days: MatchDays = match_util.create_combinations(
						league, league.get_teams_basic()
					)

					# add to list
					match_util.add_matches_to_list(league, match_days)

					# generate random results for every match
					for match_day: MatchDay in match_days.days:
						for matchz: Match in match_day.matches:
							match_engine.simulate_match(matchz, true)

					
					# create playoffs/playouts
					match_util.initialize_playoffs(league)
					match_util.initialize_playouts(league)

					# generate random results playoffs
					if league.playoffs.is_started():
						while not league.playoffs.is_over():
							# generate random results for every match
							var matches: Array[Match] = Global.world.match_list.get_matches_by_competition(league.playoffs.id)
							for matchz: Match in matches:
								if matchz.over:
									continue
								match_engine.simulate_match(matchz, true)

							league.playoffs.next_stage()

					# generate random results playouts
					if league.playouts.is_started():
						while not league.playouts.is_over():
							# generate random results for every match
							var matches: Array[Match] = Global.world.match_list.get_matches_by_competition(league.playouts.id)
							for matchz: Match in matches:
								if matchz.over:
									continue
								match_engine.simulate_match(matchz, true)

							league.playouts.next_stage()

		world.promote_and_relegate_teams()


func generate_player_history(_world: World = Global.world) -> void:
	pass

