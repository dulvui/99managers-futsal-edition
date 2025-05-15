# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Nation
extends JSONResource


@export var leagues: Array[League]
@export var cup: Cup
@export var team: Team

@export var code: String
@export var name: String

var locales: Array[Locale]
var borders: Array[String]


func _init(
	p_name: String = "",
	p_code: String = "",
	p_locales: Array[Locale] = [],
	p_borders: Array[String] = [],
	p_leagues: Array[League] = [],
	p_cup: Cup = Cup.new(),
	p_team: Team = Team.new(),
) -> void:
	name = p_name
	code = p_code
	locales = p_locales
	borders = p_borders
	leagues = p_leagues
	cup = p_cup
	team = p_team


func add_league(league: League) -> void:
	leagues.append(league)


func get_league_by_id(league_id: int) -> League:
	for league: League in leagues:
		if league.id == league_id:
			return league
	return null


func get_league_by_pyramid_level(pyramid_level: int) -> League:
	for league: League in leagues:
		if league.pyramid_level == pyramid_level:
			return league
	return null


func get_continental_cup_qualified_teams() -> Array[TeamBasic]:
	var teams: Array[TeamBasic]

	# return empty, if no league exist for nation
	if not is_competitive():
		return []

	var league: League = get_league_by_pyramid_level(1)
	var table: Array[TableValue] = league.table.to_sorted_array()

	# always qualify all teams for now
	# TODO: find better way to define number of teams
	for i: int in table.size():
		teams.append(table[i].team)

	return teams


func get_team_by_id(team_id: int) -> Team:
	for league: League in leagues:
		var found_team: Team = league.get_team_by_id(team_id)
		if found_team:
			return found_team
	push_error("error team not found with id: " + str(team_id))
	return null


func get_all_teams(include_national_team: bool = false) -> Array[Team]:
	var teams: Array[Team] = []

	if include_national_team:
		teams.append(team)

	for league: League in leagues:
		teams.append_array(league.teams)

	return teams


# to check if nation has competitions
func is_competitive() -> bool:
	return leagues.size() > 0



func promote_and_relegate() -> void:
	if leagues.size() == 0:
		return

	# d - relegated
	# p - promoted
	var teams_buffer: Dictionary[String, Dictionary] = {}
	teams_buffer["r"] = {}
	teams_buffer["p"] = {}

	# get teams that will relegate/promote
	for league: League in leagues:
		# last/first x teams will be promoted relegated
		var sorted_table: Array[TableValue] = league.table.to_sorted_array()

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
			var final_match: Match = Global.match_list.get_match_by_id(final_id)
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
			var final_match: Match = Global.match_list.get_match_by_id(final_id)
			var winner: TeamBasic = final_match.get_winner()
			if winner != null:
				var winner_team: Team = league.get_team_by_id(winner.id)
				promoted.append(winner_team)
		teams_buffer["p"][league.pyramid_level] = promoted

	# relegate/promote
	for league: League in leagues:
		var promoted: Array[Team] = teams_buffer["p"][league.pyramid_level]
		var relegated: Array[Team] = teams_buffer["r"][league.pyramid_level]

		# last league
		# only promote to upper league
		if league.pyramid_level == leagues.size():
			if leagues.size() > 1:
				# promote
				get_league_by_pyramid_level(
					league.pyramid_level - 1
				).teams.append_array(
					promoted
				)
				# remove promoted teams from league
				for p_team: Team in promoted:
					league.teams.erase(p_team)

		# intermediate leagues
		# relegate to lower league, promote to upper league
		elif league.pyramid_level > 1 and league.pyramid_level < leagues.size():
			# promote
			get_league_by_pyramid_level(
				league.pyramid_level - 1
			).teams.append_array(
				promoted
			)
			# remove promoted teams from league
			for p_team: Team in promoted:
				league.teams.erase(p_team)

			# relegate
			get_league_by_pyramid_level(
				league.pyramid_level + 1
			).teams.append_array(
				relegated
			)
			# remove relegated teams
			for r_team: Team in relegated:
				league.teams.erase(r_team)

		# best league
		# relegate to lower league, assign winners to cups
		else:
			# first teams go to cup
			# TODO add to continental cup
			#continental_cup_teams.append_array(promoted_teams)

			# add relegated teams to lower league
			get_league_by_pyramid_level(
				league.pyramid_level + 1
			).teams.append_array(
				relegated
			)

			# remove relegated teams
			for r_team: Team in relegated:
				league.teams.erase(r_team)

	# add new seasons table
	for league: League in leagues:
		# save to history and create new competitions
		league.archive_season()

		# create new tables
		for p_team: Team in league.teams:
			# first update league id
			p_team.league_id = league.id
			league.table.add_team(p_team.to_basic())

