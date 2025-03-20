# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name League
extends Competition

@export var teams: Array[Team]
# includes also historical tables
# tables[-1] is latest winner
@export var tables: Array[Table]
@export var nation_name: String
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


func _init(
	p_teams: Array[Team] = [],
	p_tables: Array[Table] = [Table.new()],
	p_nation_name: String = "",
	p_playoffs: Cup = Cup.new(),
	p_direct_promotion_teams: int = 0,
	p_playoff_teams: int = 0,
	p_direct_relegation_teams: int = 0,
	p_playout_teams: int = 0,
) -> void:
	super()
	teams = p_teams
	tables = p_tables
	nation_name = p_nation_name
	playoffs = p_playoffs
	direct_promotion_teams = p_direct_promotion_teams
	playoff_teams = p_playoff_teams
	direct_relegation_teams = p_direct_relegation_teams
	playout_teams = p_playout_teams


func table() -> Table:
	return tables[-1]


func add_team(team: Team) -> void:
	teams.append(team)
	tables[-1].add_team(team)

	# sort alphabetically
	teams.sort_custom(func(a: Team, b: Team) -> bool: return a.name < b.name)


func get_team_by_id(team_id: int) -> Team:
	for team: Team in teams:
		if team.id == team_id:
			return team
	return null
