# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Team
extends TeamBasic

@export var formation: Formation
@export var finances: Finances
# 0 to 4 active, 5 to 12 subs, 12 to x rest
@export var players: Array[Player]

@export var staff: Staff
@export var stadium: Stadium
@export var board_requests: BoardRequests
# shirt colors
# 0: home color, 1: away, 2 third color
@export var colors: Array[String]


func _init(
	p_players: Array[Player] = [],
	p_finances: Finances = Finances.new(),
	p_formation: Formation = Formation.new(),
	p_staff: Staff = Staff.new(),
	p_stadium: Stadium = Stadium.new(),
	p_board_requests: BoardRequests = BoardRequests.new(),
	p_colors: Array[String] = ["000000", "000000", "000000"],
) -> void:
	finances = p_finances
	players = p_players
	staff = p_staff
	stadium = p_stadium
	colors = p_colors
	formation = p_formation
	board_requests = p_board_requests


func set_id() -> void:
	id = IdUtil.next_id(IdUtil.Types.TEAM)


func get_goalkeeper() -> Player:
	return players[0]


func get_starting_players() -> Array[Player]:
	return players.slice(0, 5)


func get_sub_players() -> Array[Player]:
	return players.slice(5, Const.LINEUP_PLAYERS_AMOUNT)


func get_lineup_players() -> Array[Player]:
	return players.slice(0, Const.LINEUP_PLAYERS_AMOUNT)


func get_non_lineup_players() -> Array[Player]:
	return players.slice(Const.LINEUP_PLAYERS_AMOUNT, players.size())


func is_lineup_player(player: Player) -> bool:
	var index: int = players.find(player.id)
	return index >= 0 and index <= 4


func is_sub_player(player: Player) -> bool:
	var index: int = players.find(player.id)
	return index > 4 and index < Const.LINEUP_PLAYERS_AMOUNT


func change_players(p1: Player, p2: Player) -> void:
	var index1: int = players.find(p1)
	var index2: int = players.find(p2)
	players[index1] = p2
	players[index2] = p1


func remove_player(p_player: Player) -> void:
	players.erase(p_player)


func get_home_color() -> String:
	return colors[0]


func get_away_color(versus_color: String) -> String:
	if colors[1] != versus_color:
		return colors[1]
	if colors[2] != versus_color:
		return colors[2]
	return colors[0]


func get_prestige() -> int:
	# prevent division by 0
	if players.size() == 0:
		return 0

	var value: int = 0
	for player: Player in players:
		value += int(player.get_overall())
	return int(value / float(players.size()))


func get_prestige_stars() -> String:
	var relation: int = int(Const.MAX_PRESTIGE / 4.0)
	var star_factor: float = Const.MAX_PRESTIGE / float(relation)
	var stars: int = max(1, get_prestige() / star_factor)
	var spaces: int = 5 - stars
	# creates right padding example: '***  '
	return "*".repeat(stars) + "  ".repeat(spaces)


func get_basic() -> TeamBasic:
	var basic: TeamBasic = TeamBasic.new()
	basic.id = id
	basic.name = name
	basic.league_id = league_id
	return basic


func duplicate_real_deep() -> Team:
	var copy: Team = duplicate(true)
	# objects in arrays and dictionaries never get duplicated
	# https://docs.godotengine.org/en/stable/classes/class_resource.html#class-resource-method-duplicate
	copy.players = []
	for player: Player in players:
		copy.players.append(player.duplicate(true))
	return copy
