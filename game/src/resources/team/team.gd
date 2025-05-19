# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Team
extends JSONResource

@export var id: int
@export var name: String
@export var league_id: int
@export var prestige: float

@export var formation: Formation
@export var finances: Finances

@export var staff: Staff
@export var stadium: Stadium
@export var board_requests: BoardRequests
# shirt colors
# 0: home color, 1: away, 2 third color
@export var colors: Array[String]

# 0 to 4 active, 5 to 12 subs, 12 to x rest
# no export, saved as csv
var players: Array[Player]


func _init(
	p_id: int = -1,
	p_name: String = "",
	p_league_id: int = -1,
	p_prestige: float = 0.0,
	p_players: Array[Player] = [],
	p_finances: Finances = Finances.new(),
	p_formation: Formation = Formation.new(),
	p_staff: Staff = Staff.new(),
	p_stadium: Stadium = Stadium.new(),
	p_board_requests: BoardRequests = BoardRequests.new(),
	p_colors: Array[String] = [],
) -> void:
	id = p_id
	name = p_name
	league_id = p_league_id
	prestige = p_prestige
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


func get_player_by_id(player_id: int) -> Player:
	for player: Player in players:
		if player.id == player_id:
			return player
	push_error("player with id %d not found in team %s" % [player_id, name])
	return null


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


func assign_shirt_numbers() -> void:
	var used_numbers: Array[int] = []
	# find used and duplicate numbers
	for player: Player in players:
		if player.nr in used_numbers:
			player.nr = 0
		else:
			used_numbers.append(player.nr)
	# assign number to players with 0
	for player: Player in players:
		if player.nr == 0:
			for i: int in 99:
				if i in used_numbers:
					continue
				player.nr = i
				break
			used_numbers.append(player.nr)


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


func update_prestige(also_players: bool = false) -> void:
	# prevent division by 0
	if players.size() == 0:
		prestige = 0
		return

	var value: float = 0
	for player: Player in players:
		if also_players:
			player.update_prestige()
		value += player.prestige
	prestige = value / float(players.size())


func to_basic() -> TeamBasic:
	return TeamBasic.new(id, name, league_id)


func duplicate_real_deep() -> Team:
	var copy: Team = duplicate(true)
	# objects in arrays and dictionaries never get duplicated
	# https://docs.godotengine.org/en/stable/classes/class_resource.html#class-resource-method-duplicate
	copy.players = []
	for player: Player in players:
		copy.players.append(player.duplicate(true))
	return copy


