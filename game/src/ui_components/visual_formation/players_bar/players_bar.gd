# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayersBar
extends HBoxContainer

signal change_request
signal show_formation

const FormationPlayer: PackedScene = preload(Const.SCENE_FORMATION_PLAYER)

var change_players: Array[Player]
var team: Team
# flag to prevent that button sound plays while setup
var play_sound: bool

@onready var players: HBoxContainer = %Players
@onready var change_button: CheckButton = %ChangeButton


func _ready() -> void:
	play_sound = false
	change_players = []


func setup(p_team: Team) -> void:
	team = p_team

	# change button
	change_button.button_pressed = Formation.ChangeStrategy.AUTO == team.formation.change_strategy
	play_sound = true

	for player: Player in team.get_starting_players():
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		# setup
		formation_player.set_player(player)
		formation_player.select.connect(_on_formation_player_select.bind(player))
		# set node name to player id, so it can be accessed easily
		players.add_child(formation_player)
		formation_player.name = str(player.id)

	# transparent separator between players and bench
	var separator: VSeparator = VSeparator.new()
	separator.modulate = Color.TRANSPARENT
	separator.custom_minimum_size = Vector2(50, 0)
	players.add_child(separator)

	# bench
	for player: Player in team.get_sub_players():
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
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


func _on_change_button_toggled(toggled_on: bool) -> void:
	if play_sound:
		SoundUtil.play_button_sfx()
	if toggled_on:
		team.formation.change_strategy = Formation.ChangeStrategy.AUTO
	else:
		team.formation.change_strategy = Formation.ChangeStrategy.MANUAL


func _on_formation_button_pressed() -> void:
	show_formation.emit()


