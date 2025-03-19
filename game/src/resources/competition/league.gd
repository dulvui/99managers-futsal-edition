# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name League
extends Competition

@export var teams: Array[Team]
# includes also historical tables
# tables[-1] is latest winner
@export var tables: Array[Table]
@export var nation_name: String
@export var playoffs: Playoffs

@export var playoff_teams: int
@export var relegation_teams: int
@export var promotion_teams: int


func _init(
	p_teams: Array[Team] = [],
	p_tables: Array[Table] = [Table.new()],
	p_nation_name: String = "",
	p_playoffs: Playoffs = Playoffs.new()
) -> void:
	super()
	teams = p_teams
	tables = p_tables
	nation_name = p_nation_name
	playoffs = p_playoffs


func initialize_sizes(leagues_amount: int) -> void:
	if leagues_amount == 1:
		playoff_teams = 1


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
