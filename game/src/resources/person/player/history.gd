# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name History
extends JSONResource

@export var statistics: Statistics
@export var team_name: String
@export var team_id: int
@export var league_name: String
@export var league_id: int
# @export var transfer: Transfer


func _init(
	p_statistics: Statistics = Statistics.new(),
	p_team_name: String = "",
	p_team_id: int = -1,
	p_league_name: String = "",
	p_league_id: int = -1,
	# p_transfer: Transfer = Transfer.new(),
) -> void:
	statistics = p_statistics
	team_name = p_team_name
	team_id = p_team_id
	league_name = p_league_name
	league_id = p_league_id
	# transfer = p_transfer
