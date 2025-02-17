# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name World
extends JSONResource

@export var continents: Array[Continent]
@export var world_cup: Cup
@export var active_team_id: int

@export var calendar: Calendar
@export var transfers: Transfers
@export var inbox: Inbox


func _init(
	p_continents: Array[Continent] = [],
	p_world_cup: Cup = Cup.new(),
	p_active_team_id: int = -1,
	p_calendar: Calendar = Calendar.new(),
	p_transfers: Transfers = Transfers.new(),
	p_inbox: Inbox = Inbox.new(),
) -> void:
	continents = p_continents
	world_cup = p_world_cup
	active_team_id = p_active_team_id
	calendar = p_calendar
	transfers = p_transfers
	inbox = p_inbox


func from_json(dict: Dictionary) -> void:
	super(dict)

	# continents
	if dict.has("continents"):
		for continent_dict: Dictionary in dict["continents"]:
			var continent: Continent = Continent.new()
			continent.from_json(continent_dict)
			continents.append(continent)
	
	# calendar
	if dict.has("calendar"):
		var caledar_dict: Dictionary = dict["calendar"]
		calendar.from_json(caledar_dict)


func initialize() -> void:
	calendar.initialize()


func random_results() -> void:
	var match_engine: MatchEngine = MatchEngine.new()
	var matches: Array = Global.world.calendar.day().get_matches()
	for matchz: Match in matches:
		if not matchz.over:
			# set true for fast simulation
			match_engine.simulate_match(matchz,	true)

	# check if cups are ready for next stage
	for cup: Cup in get_all_cups():
		cup.next_stage()


func get_active_team() -> Team:
	return get_team_by_id(active_team_id)


func get_active_league() -> League:
	for l: League in get_all_leagues():
		for t: Team in l.teams:
			if t.id == active_team_id:
				return l
	printerr("no league/team with id " + str(active_team_id))
	return null


func get_active_nation() -> Nation:
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == Global.league.id:
					return nation
	printerr("no nation for team id " + str(active_team_id))
	return null


func get_active_continent() -> Continent:
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				if league.id == Global.league.id:
					return continent
	printerr("no continent for team id " + str(active_team_id))
	return null


func get_team_by_id(team_id: int) -> Team:
	for league: League in get_all_leagues():
		for team: Team in league.teams:
			if team.id == team_id:
				return team
	printerr("no team with id " + str(team_id))
	return null


func get_league_by_team_id(team_id: int) -> League:
	for league: League in get_all_leagues():
		for team: Team in league.teams:
			if team.id == team_id:
				return league
	printerr("no league with team id " + str(team_id))
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
		func(player: Player) -> bool:
			return player.position.type == Position.Type.G
	)
	best_goalkeepers.sort_custom(
		func(a: Player, b: Player) -> bool:
			return a.get_goalkeeper_attributes() > b.get_goalkeeper_attributes() 
	)
	best_players.append_array(best_goalkeepers.slice(0, 3))
	
	# defenders
	var best_defenders: Array[Player] = players.filter(
		func(player: Player) -> bool:
			return player.position.type in Position.defense_types
	)
	best_defenders.sort_custom(
		func(a: Player, b: Player) -> bool:
			return a.get_overall() > b.get_overall()
	)
	best_players.append_array(best_defenders.slice(0, 5))

	# centers
	var best_centers: Array[Player] = players.filter(
		func(player: Player) -> bool:
			return player.position.type in Position.center_types
	)
	best_centers.sort_custom(
		func(a: Player, b: Player) -> bool:
			return a.get_overall() > b.get_overall()
	)
	best_players.append_array(best_centers.slice(0, 5))

	# attackers
	var best_attackers: Array[Player] = players.filter(
		func(player: Player) -> bool:
			return player.position.type in Position.attack_types
	)
	best_attackers.sort_custom(
		func(a: Player, b: Player) -> bool:
			return a.get_overall() > b.get_overall()
	)
	best_players.append_array(best_attackers.slice(0, 5))

	return best_players


func get_all_nations() -> Array[Nation]:
	var all_nations: Array[Nation] = []
	for continent: Continent in continents:
		all_nations.append_array(continent.nations)
	return all_nations


func get_all_leagues() -> Array[League]:
	var leagues: Array[League] = []
	for continent: Continent in continents:
		for nation: Nation in continent.nations:
			leagues.append_array(nation.leagues)
	return leagues


func get_all_cups() -> Array[Cup]:
	var cups: Array[Cup] = []
	# world
	cups.append(world_cup)
	# continent
	for contient: Continent in continents:
		cups.append(contient.cup_clubs)
		cups.append(contient.cup_nations)
		# nations
		for nation: Nation in contient.nations:
			cups.append(nation.cup)
	return cups


func get_all_teams(include_national_teams: bool = false) -> Array[Team]:
	var teams: Array[Team] = []

	for nation: Nation in get_all_nations():
		teams.append_array(nation.get_all_teams(include_national_teams))

	return teams


func promote_and_delegate_teams() -> void:
	for contient: Continent in continents:
		for nation: Nation in contient.nations:
			# d - delegated
			# p - promoted
			var teams_buffer: Dictionary = {}
			teams_buffer["d"] = {}
			teams_buffer["p"] = {}

			# get teams that will delegate promote
			for league: League in nation.leagues:
				# last/first x teams will be promoted delegated
				var sorted_table: Array[TableValues] = league.table().to_sorted_array()

				# assign delegated
				teams_buffer["d"][league.pyramid_level] = (
					league
					. teams
					. filter(
						func(t: Team) -> bool: return (
							# get last 2 teams
							t.id == sorted_table[-1].team_id
							|| t.id == sorted_table[-2].team_id
						)
					)
				)
				# assign promoted
				teams_buffer["p"][league.pyramid_level] = (
					league
					. teams
					. filter(
						func(t: Team) -> bool: return (
							# get first 2 teams
							t.id == sorted_table[0].team_id
							|| t.id == sorted_table[1].team_id
						)
					)
				)

			# delegate/promote
			for league: League in nation.leagues:
				var promoted_teams: Array[Team] = teams_buffer["p"][league.pyramid_level]
				var delegated_teams: Array[Team] = teams_buffer["d"][league.pyramid_level]

				# start with backup teams
				# prevents array out of bounds, in case if only one league in nation
				# this code runs if this is last league by pyramid level or only one league is present
				if league.pyramid_level == nation.leagues.size():
					# make sure there are as many backup teams as delegated
					if nation.backup_teams.size() < delegated_teams.size():
						delegated_teams = delegated_teams.slice(0, nation.backup_teams.size())

					# remove delegated from league
					for team: Team in delegated_teams:
						league.teams.erase(team)

					# add backup teams to league
					for i: int in delegated_teams.size():
						var backup: Team = RngUtil.pick_random(nation.backup_teams)
						nation.backup_teams.erase(backup)
						league.teams.append(backup)

					# add delegated to backup tems
					nation.backup_teams.append_array(delegated_teams)

					if nation.leagues.size() > 1:
						# promote
						(
							nation
							. get_league_by_pyramid_level(league.pyramid_level - 1)
							. teams
							. append_array(promoted_teams)
						)
						# remove promoted teams from league
						for team: Team in promoted_teams:
							league.teams.erase(team)
					#else:
					# TODO add to ocntinental cup
					# add to cup, if only league in nation
					#continental_cup_teams.append_array(promoted_teams)

				elif league.pyramid_level > 1:
					# promote
					nation.get_league_by_pyramid_level(league.pyramid_level - 1).teams.append_array(
						promoted_teams
					)
					# remove promoted teams from league
					for team: Team in promoted_teams:
						league.teams.erase(team)

					# delegate
					nation.get_league_by_pyramid_level(league.pyramid_level + 1).teams.append_array(
						delegated_teams
					)
					# remove delegated teams
					for team: Team in delegated_teams:
						league.teams.erase(team)

				else:
					# first teams go to cup
					# TODO add to continental cup
					#continental_cup_teams.append_array(promoted_teams)

					# add delegated teams to lower league
					nation.get_league_by_pyramid_level(league.pyramid_level + 1).teams.append_array(
						delegated_teams
					)

					# remove delegated teams
					for team: Team in delegated_teams:
						league.teams.erase(team)

			# add new seasons table
			for league: League in nation.leagues:
				var table: Table = Table.new()
				for team: Team in league.teams:
					table.add_team(team)
				league.tables.append(table)


