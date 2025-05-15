# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorHistory

# defines year, when history starts
const HISTORY_YEARS: int = 5

var rng_util: RngUtil


func _init(p_rng_util: RngUtil) -> void:
	rng_util = p_rng_util


func generate_club_history(world: World) -> void:
	# TODO world cup history (once national teams exist)
	# TODO continental national teams cup
	var match_util: MatchUtil = MatchUtil.new(rng_util)
	var match_engine: MatchEngine = MatchEngine.new()

	# save initial leagues by team
	# after history generation, team ids get swapped to play in the right initial league
	# so that teams play in league as defined in csv
	var leagues_by_teams: Dictionary[String, Array] = {}
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				leagues_by_teams[league.name] = []
				for team: Team in league.teams:
					leagues_by_teams[league.name].append(team)

	# calculate random results for x years
	for year: int in HISTORY_YEARS:
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
							var matches: Array[Match] = Global.match_list.\
									get_matches_by_competition(league.playoffs.id)
							for matchz: Match in matches:
								if matchz.over:
									continue
								match_engine.simulate_match(matchz, true)

							league.playoffs.next_stage()

					# generate random results playouts
					if league.playouts.is_started():
						while not league.playouts.is_over():
							# generate random results for every match
							var matches: Array[Match] = Global.match_list.\
									get_matches_by_competition(league.playouts.id)
							for matchz: Match in matches:
								if matchz.over:
									continue
								match_engine.simulate_match(matchz, true)

							league.playouts.next_stage()

		for continent: Continent in world.continents:
			for nation: Nation in continent.nations:
				nation.promote_and_relegate()

		Global.match_list.archive_season()

	# get which team ids/names need to be swapped
	var teams_id_mapping: Dictionary[int, int] = {}
	var teams_name_mapping: Dictionary[String, String] = {}
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for i: int in leagues_by_teams[league.name].size():
					var initial_team: Team = leagues_by_teams[league.name][i]
					var current_team: Team = league.teams[i]
					teams_id_mapping[current_team.id] = initial_team.id
					teams_name_mapping[current_team.name] = initial_team.name

	# swap team names and ids in leagues
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					team.id = teams_id_mapping[team.id]
					team.name = teams_name_mapping[team.name]

	# swap team names and ids in matches
	for match_days: MatchDays in Global.match_list.history_match_days:
		for match_day: MatchDay in match_days.days:
			for matchz: Match in match_day.matches:
				matchz.home.id = teams_id_mapping[matchz.home.id]
				matchz.home.name = teams_name_mapping[matchz.home.name]
				matchz.away.id = teams_id_mapping[matchz.away.id]
				matchz.away.name = teams_name_mapping[matchz.away.name]


func generate_player_history(_world: World) -> void:
	pass

