# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayersBar
extends ScrollContainer


signal change_request

const FormationPlayer: PackedScene = preload("res://src/ui_components/visual_formation/player/formation_player.tscn")

var change_players: Array[Player]
var team: Team

@onready var players: HBoxContainer = %Players
@onready var change_strategy_select: SwitchOptionButton = %ChangeStrategySelect


func _ready() -> void:
	change_players = []
	

func setup(p_team: Team) -> void:
	team = p_team
	
	change_strategy_select.setup(Formation.ChangeStrategy.keys(), team.formation.change_strategy)

	for player: Player in team.get_starting_players():
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		# setup
		formation_player.set_player(player)
		formation_player.select.connect(_on_formation_player_select.bind(player))
		# set node name to player id, so it can be accessed easily
		players.add_child(formation_player)
		formation_player.name = str(player.id)
	
	players.add_child(VSeparator.new())
	
	# bench
	for player: Player in team.get_sub_players():
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		# setup
		formation_player.set_player(player)
		formation_player.select.connect(_on_formation_player_select.bind(player))
		# set unique node name to player id, so it can be accessed easily
		players.add_child(formation_player)
		formation_player.name = str(player.id)


func update_players() -> void:
	for i: int in team.get_lineup_players().size():
		var player: Player = team.players[i]
		var visual_player: VisualFormationPlayer = players.get_node(str(player.id))
		players.move_child(visual_player, i)


func _on_formation_player_select(player: Player) -> void:
	if player not in change_players:
		change_players.append(player)
		if change_players.size() == 2:
			# access player easily with player id set as node name in setup
			var id0: String = str(change_players[0].id)
			var id1: String = str(change_players[1].id)
			var player0: VisualFormationPlayer = players.get_node(id0)
			var player1: VisualFormationPlayer = players.get_node(id1)
			var index0: int = player0.get_index()
			var index1: int = player1.get_index()
			players.move_child(player0, index1)
			players.move_child(player1, index0)

			team.change_players(change_players[0], change_players[1])
			change_request.emit()
			
			change_players.clear()
	else:
		change_players.erase(player)


func _on_change_strategy_select_item_selected(index: int) -> void:
	team.formation.change_strategy = index


