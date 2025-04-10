# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name World
extends JSONResource

@export var continents: Array[Continent]
@export var world_cup: Cup
@export var active_team_id: int

@export var match_list: MatchList
@export var transfers: Transfers
@export var calendar: Calendar
@export var inbox: Inbox


func _init(
	p_continents: Array[Continent] = [],
	p_world_cup: Cup = Cup.new(),
	p_active_team_id: int = -1,
	p_calendar: Calendar = Calendar.new(),
	p_transfers: Transfers = Transfers.new(),
	p_inbox: Inbox = Inbox.new(),
	p_match_list: MatchList = MatchList.new(),
) -> void:
	continents = p_continents
	world_cup = p_world_cup
	active_team_id = p_active_team_id
	calendar = p_calendar
	transfers = p_transfers
	inbox = p_inbox
	match_list = p_match_list


func random_results() -> void:
	var match_engine: MatchEngine = MatchEngine.new()
	var matches: Array[Match] = match_list.get_matches_by_day()
	for matchz: Match in matches:
		if not matchz.has_active_team() and not matchz.over:
			# set true for fast simulation
			match_engine.simulate_match(matchz, true)


func get_active_team() -> Team:
	return get_team_by_id(active_team_id)


func get_active_league() -> League:
	for l: League in get_all_leagues():
		for t: Team in l.teams:
			if t.id == active_team_id:
				return l
	push_error("no league/team with id " + str(active_team_id))
	return null


func get_active_nation() -> Nation:
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == Global.league.id:
					return nation
	push_error("no nation for team id " + str(active_team_id))
	return null


func get_active_continent() -> Continent:
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == Global.league.id:
					return continent
	push_error("no continent for team id " + str(active_team_id))
	return null


func get_continent_by_code(code: String) -> Continent:
	for continent: Continent in continents:
		if continent.code == code:
			return continent
	push_error("no continent with code %s found." % code)
	return null


func get_nation_by_code(code: String, p_continent: Continent = null) -> Nation:
	if p_continent != null:
		for nation: Nation in p_continent.nations:
			if nation.code == code:
				return nation

	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			if nation.code == code:
				return nation
	push_error("no nation with code %s found." % code)
	return null


func get_team_by_id(team_id: int, league_id: int = -1) -> Team:
	if league_id > -1:
		var league: League = get_league_by_id(league_id)
		if league != null:
			for team: Team in league.teams:
				if team.id == team_id:
					return team

	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			if nation.team.id == team_id:
				return nation.team
			for league: League in nation.leagues:
				for team: Team in league.teams:
					if team.id == team_id:
						return team
	push_error("no team with id " + str(team_id))
	return null


func get_league_by_id(league_id: int, p_nation: Nation = null) -> League:
	if p_nation != null:
		for league: League in p_nation.leagues:
			if league.id == league_id:
				return league

	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == league_id:
					return league
	push_error("no league with id " + str(league_id))
	return null


func get_league_by_name(league_name: String, p_nation: Nation = null) -> League:
	if p_nation != null:
		for league: League in p_nation.leagues:
			if league.name == league_name:
				return league

	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.name == league_name:
					return league
	push_warning("no league with name " + str(league_name))
	return null


func get_competition_by_id(competition_id: int) -> Competition:
	if world_cup.id == competition_id:
		return world_cup
	for continent: Continent in continents:
		if continent.cup_clubs.id == competition_id:
			return continent.cup_clubs
		if continent.cup_nations.id == competition_id:
			return continent.cup_nations
		for nation: Nation in continent.nations:
			if nation.cup.id == competition_id:
				return nation.cup
			for league: League in nation.leagues:
				if league.id == competition_id:
					return league
				if league.playoffs.id == competition_id:
					return league.playoffs
				if league.playouts.id == competition_id:
					return league.playouts
	push_error("no competition with id " + str(competition_id))
	return null


func get_all_players() -> Array[Player]:
	var players: Array[Player] = []
	for league: League in get_all_leagues():
		for team: Team in league.teams:
			players.append_array(team.players)
	return players


func get_all_players_by_nationality(nation: Nation) -> Array[Player]:
	var players: Array[Player] = []
	for league: League in get_all_leagues():
		for team: Team in league.teams:
			for player: Player in team.players:
				if player.nation == nation.name:
					players.append(player)
	return players


func get_best_players_by_nationality(nation: Nation) -> Array[Player]:
	var best_players: Array[Player] = []
	var players: Array[Player] = get_all_players_by_nationality(nation)

	# goal keepers
	var best_goalkeepers: Array[Player] = players.filter(
		func(player: Player) -> bool: return player.position.main == Position.Type.G
	)
	best_goalkeepers.sort_custom(
		func(a: Player, b: Player) -> bool: return (
			a.get_goalkeeper_attributes() > b.get_goalkeeper_attributes()
		)
	)
	best_players.append_array(best_goalkeepers.slice(0, 3))

	# defenders
	var best_defenders: Array[Player] = players.filter(
		func(player: Player) -> bool: return player.position.main in Position.defense_types
	)
	best_defenders.sort_custom(
		func(a: Player, b: Player) -> bool: return a.get_overall() > b.get_overall()
	)
	best_players.append_array(best_defenders.slice(0, 5))

	# centers
	var best_centers: Array[Player] = players.filter(
		func(player: Player) -> bool: return player.position.main in Position.center_types
	)
	best_centers.sort_custom(
		func(a: Player, b: Player) -> bool: return a.get_overall() > b.get_overall()
	)
	best_players.append_array(best_centers.slice(0, 5))

	# attackers
	var best_attackers: Array[Player] = players.filter(
		func(player: Player) -> bool: return player.position.main in Position.attack_types
	)
	best_attackers.sort_custom(
		func(a: Player, b: Player) -> bool: return a.get_overall() > b.get_overall()
	)
	best_players.append_array(best_attackers.slice(0, 5))

	return best_players


func get_all_nations(sorted_alphabetically: bool = false) -> Array[Nation]:
	var all_nations: Array[Nation] = []
	for continent: Continent in continents:
		all_nations.append_array(continent.nations)

	if sorted_alphabetically:
		all_nations.sort_custom(func(a: Nation, b: Nation) -> bool: return a.name < b.name)
	
	return all_nations


func get_all_leagues(competitive: bool = false) -> Array[League]:
	var leagues: Array[League] = []
	for continent: Continent in continents:
		if not competitive or continent.is_competitive():
			for nation: Nation in continent.nations:
				leagues.append_array(nation.leagues)
	return leagues


func get_all_cups() -> Array[Cup]:
	var cups: Array[Cup] = []
	# world
	if world_cup.is_active():
		cups.append(world_cup)
	# continent
	for contient: Continent in continents:
		if contient.cup_clubs.is_active():
			cups.append(contient.cup_clubs)
		if contient.cup_nations.is_active():
			cups.append(contient.cup_nations)
		# nations
		for nation: Nation in contient.nations:
			if nation.cup.is_active():
				cups.append(nation.cup)
	return cups


func get_all_teams(include_national_teams: bool = false) -> Array[Team]:
	var teams: Array[Team] = []

	for nation: Nation in get_all_nations():
		teams.append_array(nation.get_all_teams(include_national_teams))

	return teams


func promote_and_relegate_teams() -> void:
	for contient: Continent in continents:
		for nation: Nation in contient.nations:
			if nation.leagues.size() == 0:
				continue

			# d - relegated
			# p - promoted
			var teams_buffer: Dictionary[String, Dictionary] = {}
			teams_buffer["r"] = {}
			teams_buffer["p"] = {}

			# get teams that will relegate/promote
			for league: League in nation.leagues:
				# last/first x teams will be promoted relegated
				var sorted_table: Array[TableValues] = league.table.to_sorted_array()

				# assign direct relegated
				var relegated: Array[Team] = league.teams.filter(
					func(t: Team) -> bool:
						for i: int in range(-1, -league.direct_relegation_teams -1, -1):
							if t.id == sorted_table[i].team.id:
								return true
						return false
				)
				# assign playouts looser
				if league.playouts.is_over():
					var final_id: int = league.playouts.knockout.final_ids[-1]
					var final_match: Match = Global.world.match_list.get_match_by_id(final_id)
					var runner_up: TeamBasic = final_match.get_looser()
					if runner_up != null:
						var runner_up_team: Team = league.get_team_by_id(runner_up.id)
						relegated.append(runner_up_team)

				teams_buffer["r"][league.pyramid_level] = relegated

				# assign direct promoted
				var promoted: Array[Team] = league.teams.filter(
					func(t: Team) -> bool:
						for i: int in league.direct_promotion_teams:
							if t.id == sorted_table[i].team.id:
								return true
						return false
				)
				# assign playoffs winner
				if league.playoffs.is_over():
					var final_id: int = league.playoffs.knockout.final_ids[-1]
					var final_match: Match = Global.world.match_list.get_match_by_id(final_id)
					var winner: TeamBasic = final_match.get_winner()
					if winner != null:
						var winner_team: Team = league.get_team_by_id(winner.id)
						promoted.append(winner_team)
				teams_buffer["p"][league.pyramid_level] = promoted

			# relegate/promote
			for league: League in nation.leagues:
				var promoted: Array[Team] = teams_buffer["p"][league.pyramid_level]
				var relegated: Array[Team] = teams_buffer["r"][league.pyramid_level]

				# last league
				# only promote to upper league
				if league.pyramid_level == nation.leagues.size():
					if nation.leagues.size() > 1:
						# promote
						nation.get_league_by_pyramid_level(league.pyramid_level - 1).teams.append_array(
							promoted
						)
						# remove promoted teams from league
						for team: Team in promoted:
							league.teams.erase(team)

				# intermediate leagues
				# relegate to lower league, promote to upper league
				elif league.pyramid_level > 1 and league.pyramid_level < nation.leagues.size():
					# promote
					nation.get_league_by_pyramid_level(league.pyramid_level - 1).teams.append_array(
						promoted
					)
					# remove promoted teams from league
					for team: Team in promoted:
						league.teams.erase(team)

					# relegate
					nation.get_league_by_pyramid_level(league.pyramid_level + 1).teams.append_array(
						relegated
					)
					# remove relegated teams
					for team: Team in relegated:
						league.teams.erase(team)

				# best league
				# relegate to lower league, assign winners to cups
				else:
					# first teams go to cup
					# TODO add to continental cup
					#continental_cup_teams.append_array(promoted_teams)

					# add relegated teams to lower league
					nation.get_league_by_pyramid_level(league.pyramid_level + 1).teams.append_array(
						relegated
					)

					# remove relegated teams
					for team: Team in relegated:
						league.teams.erase(team)

			# add new seasons table
			for league: League in nation.leagues:
				# save to history and create new competitions
				league.archive_season()
				
				for team: Team in league.teams:
					league.table.add_team(team)
					# reassign all league ids
					team.league_id = league.id

	match_list.archive_season()

