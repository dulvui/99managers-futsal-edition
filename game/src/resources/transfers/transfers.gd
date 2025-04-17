# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Transfers
extends JSONResource

@export var list: Array[Transfer]


func _init(
	p_list: Array[Transfer] = [],
) -> void:
	list = p_list


func get_by_player_id(player_id: int, team_id: int = Global.team.id) -> Transfer:
	for transfer: Transfer in list:
		if transfer.offer_team.id == team_id and transfer.player_id == player_id:
			return transfer
	return null

