# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Group
extends JSONResource

@export var table: Table
@export var teams: Array[Team]


func _init(
	p_table: Table = Table.new(),
	p_teams: Array[Team] = [],
) -> void:
	table = p_table
	teams = p_teams


func add_team(team: Team) -> void:
	teams.append(team)
	table.add_team(team)

	# sort alphabetically
	teams.sort_custom(func(a: Team, b: Team) -> bool: return a.name < b.name)


func get_team_by_id(team_id: int) -> Team:
	for team: Team in teams:
		if team.id == team_id:
			return team
	return null


func sort_teams_by_table_pos() -> void:
	teams.sort_custom(
		func(a: Team, b: Team) -> bool: return table.get_position(a.id) > table.get_position(b.id)
	)


func is_over() -> bool:
	# on the premise, that teams play twice against each other
	var over_count: int = 0
	for table_value: TableValues in table.teams:
		if table_value.games_played == teams.size() - 2:
			over_count += 1

	return over_count == teams.size()
