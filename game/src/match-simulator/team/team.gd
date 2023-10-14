# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node2D

enum Mentality {ULTRA_OFFENSIVE, OFFENSIVE, NORMAL, DEFENSIVE, ULTRA_DEFENSIVE}
enum Passing {LONG, SHORT, DIRECT, NORMAL}
enum Formations {TT=22,OTO=121,OOT=112,TOO=211,TO=31,OT=13}

var players
var goalkeeper:Goalkeeper

# trainer tactics settings
var tactics = {
	"formation" : Formations.TT,
	"mentality" : Mentality.NORMAL,
	"pressing" : false,
	"counter_attack" : false,
	"passing" : Passing.NORMAL,
}

# to calculate possession
var possession_counter = 0.0

var has_ball = false

# player that is attacking/defending
var active_player

func set_up(team:Team) -> void: # TODO add tactics
	players = []
	var team_players = team.line_up.players
	goalkeeper = Goalkeeper.instantiate()
	goalkeeper.set_up(team.line_up.goalkeeper)
	
	for i in team_players.size() - 1:
		var player = Player.instantiate()
		player.set_up(team_players[i + 1])
		players.append(player)

	active_player = players[-1]
	
func update_players() -> void:
	for player in players:
		player.update()

func change_active_player() -> void:
	var other_players = players.duplicate()
	other_players.remove_at(players.find(active_player))
	
	active_player = other_players[(randi() % other_players.size())]


