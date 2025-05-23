# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Table
extends JSONResource

@export var teams: Array[TableValue]


func _init(
	p_teams: Array[TableValue] = [],
) -> void:
	teams = p_teams


func add_team(team: TeamBasic) -> void:
	var values: TableValue = TableValue.new()
	# make sure team is basic
	values.team = TeamBasic.new(team.id, team.name, team.league_id)
	teams.append(values)


func add_result(
	home_id: int,
	away_id: int,
	home_goals: int,
	away_goals: int,
	home_penalties_goals: int = 0,
	away_penalties_goals: int = 0,
) -> void:
	var home: TableValue = _find_by_id(home_id)
	var away: TableValue = _find_by_id(away_id)
	home.save_result(home_goals, away_goals, home_penalties_goals, away_penalties_goals)
	away.save_result(away_goals, home_goals, away_penalties_goals, home_penalties_goals)


func get_position(team_id: int = Global.team.id) -> int:
	var list: Array[TableValue] = to_sorted_array()
	for table_value: TableValue in list:
		if table_value.team.id == team_id:
			return list.find(table_value) + 1
	print("error finding team position for team id " + str(team_id))
	return -1


func to_sorted_array() -> Array[TableValue]:
	var sorted: Array[TableValue] = teams.duplicate()
	sorted.sort_custom(_point_sorter)
	return sorted


# ascending, 0 best, size -1 last
func _point_sorter(a: TableValue, b: TableValue) -> bool:
	if a.games_played == 0 and b.games_played == 0:
		return a.team.name < b.team.name
	if a.points > b.points:
		return true
	if a.points == b.points and a.goals_made - a.goals_conceded > b.goals_made - b.goals_conceded:
		return true
	return false


func _find_by_id(team_id: int) -> TableValue:
	for value: TableValue in teams:
		if value.team.id == team_id:
			return value
	push_error("error while searching team in table with id: " + str(team_id))
	return null

