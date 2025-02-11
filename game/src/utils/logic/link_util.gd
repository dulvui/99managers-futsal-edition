# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal team_link(team: Team)
signal player_link(player: Player)


func link_team_id(team_id: int) -> void:
	var team: Team = Global.world.get_team_by_id(team_id)
	if team != null:
		SoundUtil.play_button_sfx()
		team_link.emit(team)

