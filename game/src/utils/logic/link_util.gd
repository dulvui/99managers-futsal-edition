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


func link_player_id(player_id: int, team_id: int) -> void:
	var team: Team = Global.world.get_team_by_id(team_id)
	if team != null:
		for player: Player in team.players:
			if player.id == player_id:
				SoundUtil.play_button_sfx()
				player_link.emit(player)
				return


func get_team_url(team_id: int, team_name: String) -> String:
	return "[url=t%s]%s[/url]" % [team_id, team_name]


# func get_player_url(player_id: int, player_name: String, team_id: int) -> String:
# 	return "[url=p%s/t%s]%s[/url]" % [player_id, team_id, player_name]


func get_player_url(player: Player) -> String:
	return "[url=p%s/t%s]%s[/url]" % [player.id, player.team_id, player.get_full_name()]
