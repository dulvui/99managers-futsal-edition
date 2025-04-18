# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name FreeAgents
extends Resource

var list: Array[Player] = []


func _init(
	p_list: Array[Player] = [],
) -> void:
	list = p_list


func get_player_by_id(player_id: int) -> Player:
	for player: Player in list:
		if player.id == player_id:
			return player
	return null


func append(player: Player) -> void:
	player.team = ""
	player.league = ""
	player.league_id = 0
	player.team_id = 0
	player.value = 0
	list.append(player)

