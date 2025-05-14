# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name World
extends JSONResource

@export var continents: Array[Continent]
@export var world_cup: Cup
@export var active_team_id: int

# only csv resource that makes sense here
var free_agents: FreeAgents


func _init(
	p_continents: Array[Continent] = [],
	p_world_cup: Cup = Cup.new(),
	p_active_team_id: int = -1,
	p_free_agents: FreeAgents = FreeAgents.new(),
) -> void:
	continents = p_continents
	world_cup = p_world_cup
	active_team_id = p_active_team_id
	free_agents = p_free_agents


func get_active_team() -> Team:
	return get_team_by_id(active_team_id)


func get_active_league() -> League:
	for l: League in get_all_leagues():
		for t: Team in l.teams:
			if t.id == active_team_id:
				return l
	push_error("no active league found with team id %d" % active_team_id)
	return null


func get_active_nation() -> Nation:
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == Global.league.id:
					return nation
	push_error("no active nation found for team id %d" % active_team_id)
	return null


func get_active_continent() -> Continent:
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == Global.league.id:
					return continent
	push_error("no active continent for team id %d" % active_team_id)
	return null


func get_continent_by_code(code: String) -> Continent:
	for continent: Continent in continents:
		if continent.code == code:
			return continent
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
	return null


func get_all_players() -> Array[Player]:
	var players: Array[Player] = []

	# team players
	for league: League in get_all_leagues():
		for team: Team in league.teams:
			players.append_array(team.players)

	# free agents
	players.append_array(free_agents.list)

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
