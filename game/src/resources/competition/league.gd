# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name League
extends Competition

@export var teams: Array[Team]
@export var nation_name: String
# active table and playoffs/playouts
@export var table: Table
@export var playoffs: Cup
@export var playouts: Cup

# in highest league, playoffs define final winner and continental cup participants
# total promotion and total reletations teams from leagues must be the same
# total promotion = direct_promotion_teams + playoffs winner
# total delegation = direct_relegation_teams + playouts looser
@export var direct_promotion_teams: int
@export var playoff_teams: int
@export var direct_relegation_teams: int
@export var playout_teams: int

# history
@export var history_tables: Array[Table]
@export var history_playoffs: Array[Cup]
@export var history_playouts: Array[Cup]


func _init(
	p_teams: Array[Team] = [],
	p_nation_name: String = "",
	p_table: Table = Table.new(),
	p_playoffs: Cup = Cup.new(),
	p_playouts: Cup = Cup.new(),
	p_history_tables: Array[Table] = [],
	p_history_playoffs: Array[Cup] = [],
	p_history_playouts: Array[Cup] = [],
	p_direct_promotion_teams: int = 0,
	p_playoff_teams: int = 0,
	p_direct_relegation_teams: int = 0,
	p_playout_teams: int = 0,
) -> void:
	super()
	teams = p_teams
	nation_name = p_nation_name
	table = p_table
	playoffs = p_playoffs
	playouts = p_playouts
	history_tables = p_history_tables
	history_playoffs = p_history_playoffs
	history_playouts = p_history_playouts
	direct_promotion_teams = p_direct_promotion_teams
	playoff_teams = p_playoff_teams
	direct_relegation_teams = p_direct_relegation_teams
	playout_teams = p_playout_teams

	playoffs.name = tr("Playoffs") + " " + name
	playouts.name = tr("Playouts") + " " + name


func add_team(team: Team) -> void:
	teams.append(team)
	table.add_team(team)

	# sort alphabetically
	teams.sort_custom(func(a: Team, b: Team) -> bool: return a.name < b.name)


func get_team_by_id(team_id: int) -> Team:
	for team: Team in teams:
		if team.id == team_id:
			return team
	push_error("no team with id %d" % team_id)
	return null


func get_team_by_name(team_name: String) -> Team:
	for team: Team in teams:
		if team.name == team_name:
			return team
	push_warning("no team with name %s" % team_name)
	return null


func get_teams_basic() -> Array[TeamBasic]:
	var teams_basic: Array[TeamBasic] = []
	for team: Team in teams:
		teams_basic.append(team.get_basic())
	return teams_basic


func archive_season() -> void:
	# append to history
	history_tables.append(table.duplicate(true))
	if playoff_teams > 0:
		history_playoffs.append(playoffs.duplicate(true))
	if playout_teams > 0:
		history_playouts.append(playouts.duplicate(true))
	
	# new season
	table = Table.new()
	playoffs = Cup.new()
	playouts = Cup.new()
	playoffs.name = tr("Playoffs") + " " + name
	playouts.name = tr("Playouts") + " " + name

