# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorHistory

# defines year, when history starts
const HISTORY_YEARS: int = 10


func generate_club_history(world: World = Global.world) -> void:
	# TODO world cup history (once national teams exist)
	# TODO continental national teams cup

	var match_util: MatchUtil = MatchUtil.new(world)
	var match_engine: MatchEngine = MatchEngine.new()

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
							match_engine.simulate_match(matchz, true)

					# create playoffs/playouts
					match_util.initialize_playoffs(league, false)
					match_util.initialize_playouts(league, false)

					# generate random results playoffs
					if league.playoffs.is_started():
						while not league.playoffs.is_over():
							# generate random results for every match
							var play_match_days: Array[Array] = league.playoffs.get_matches()
							for match_day: Array in play_match_days:
								for matchz: Match in match_day:
									match_engine.simulate_match(matchz, true)

							league.playoffs.next_stage(false)

					# generate random results playouts
					if league.playouts.is_started():
						while not league.playouts.is_over():
							# generate random results for every match
							var play_match_days: Array[Array] = league.playouts.get_matches()
							for match_day: Array in play_match_days:
								for matchz: Match in match_day:
									match_engine.simulate_match(matchz, true)

							league.playouts.next_stage(false)

		world.promote_and_relegate_teams()


func generate_player_history(_world: World = Global.world) -> void:
	pass

