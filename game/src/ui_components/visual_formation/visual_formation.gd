# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualFormation
extends HBoxContainer

signal change_request
signal tactic_request
signal formation_request

const FormationPlayer: PackedScene = preload(Const.SCENE_FORMATION_PLAYER)

var team: Team
var change_players: Array[VisualFormationPlayer]
var only_lineup: bool

@onready var formation_select: SwitchOptionButton = %FormationSelect
@onready var change_strategy_select: SwitchOptionButton = %ChangeStrategySelect
@onready var tactic_select_offense: SwitchOptionButton = %TacticSelectOffense
@onready var tactic_offense_intensity: HSlider = %TacticOffenseIntensity
@onready var tactic_select_pressing: SwitchOptionButton = %TacticSelectPressing
@onready var tactic_select_marking: SwitchOptionButton = %TacticSelectMarking

@onready var field: VisualField = %VisualField
@onready var camera: Camera2D = %Camera2D

@onready var lineup: VBoxContainer = %LineUp
@onready var goalkeeper: HBoxContainer = %Goalkeeper
@onready var defense: HBoxContainer = %Defense
@onready var center: HBoxContainer = %Center
@onready var attack: HBoxContainer = %Attack

@onready var subs: VBoxContainer = %SubsList


func _ready() -> void:
	# setup automatically, if run in editor and is run by 'Run current scene'
	if Tests.is_run_as_current_scene(self):
		setup(false, Tests.create_mock_team())

	change_players = []
	camera.zoom = Vector2(1.0 / Global.config.theme_scale, 1.0 / Global.config.theme_scale)

	field.setup(SimField.new(RandomNumberGenerator.new()))
	


func setup(p_only_lineup: bool, p_team: Team = Global.team) -> void:
	only_lineup = p_only_lineup
	team = p_team

	# set up fomation options
	formation_select.setup(Formation.Variations.keys(), team.formation.variation)
	change_strategy_select.setup(Formation.ChangeStrategy.keys(), team.formation.change_strategy)

	# tactics offense
	tactic_select_offense.setup(
		TacticOffense.Tactics.keys(),
		TacticOffense.Tactics.values()[team.formation.tactic_offense.tactic]
	)

	tactic_offense_intensity.value = team.formation.tactic_offense.intensity

	# tactics defense
	tactic_select_marking.setup(
		TacticDefense.Marking.keys(),
		TacticDefense.Marking.values()[team.formation.tactic_defense.marking]
	)
	tactic_select_pressing.setup(
		TacticDefense.Pressing.keys(),
		TacticDefense.Pressing.values()[team.formation.tactic_defense.pressing]
	)

	set_players()


func set_players() -> void:
	change_players.clear()

	# clean field
	for hbox: HBoxContainer in lineup.get_children():
		for player: Control in hbox.get_children():
			player.queue_free()

	# clean subs
	for sub: Control in subs.get_children():
		sub.queue_free()

	var pos_count: int = 0
	# add golakeeper
	if team.formation.goalkeeper > 0:
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		formation_player.set_player(team.get_goalkeeper())
		formation_player.select.connect(_on_select_player.bind(formation_player))
		goalkeeper.add_child(formation_player)
		pos_count += 1

	# add defenders
	for i: int in team.formation.defense:
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		formation_player.set_player(team.players[pos_count], team)
		formation_player.select.connect(_on_select_player.bind(formation_player))
		defense.add_child(formation_player)
		pos_count += 1

	# add center
	for i: int in team.formation.center:
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		formation_player.set_player(team.players[pos_count], team)
		formation_player.select.connect(_on_select_player.bind(formation_player))
		center.add_child(formation_player)
		pos_count += 1

	# add attack
	for i: int in team.formation.attack:
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		formation_player.set_player(team.players[pos_count], team)
		formation_player.select.connect(_on_select_player.bind(formation_player))
		attack.add_child(formation_player)
		pos_count += 1

	# add subs
	var subs_label: Label = Label.new()
	subs_label.text = tr("Subs")
	subs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subs.add_child(subs_label)

	for i: int in team.get_sub_players().size():
		var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
		formation_player.set_player(team.players[pos_count], team)
		formation_player.select.connect(_on_select_player.bind(formation_player))
		subs.add_child(formation_player)
		pos_count += 1

	if not only_lineup:
		subs.add_child(HSeparator.new())
		# add non lineup players
		var non_lineup_label: Label = Label.new()
		non_lineup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		non_lineup_label.text = tr("Rest")
		subs.add_child(non_lineup_label)

		for p: Player in team.get_non_lineup_players():
			var formation_player: VisualFormationPlayer = FormationPlayer.instantiate()
			formation_player.set_player(p, team)
			formation_player.select.connect(_on_select_player.bind(formation_player))
			subs.add_child(formation_player)


func _update_formation(index: int) -> void:
	team.formation = Formation.new(index)
	set_players()


func _on_select_player(player: VisualFormationPlayer) -> void:
	if player not in change_players:
		change_players.append(player)
		if change_players.size() == 2:
			_change_player()
	else:
		change_players.erase(player)


func _change_player() -> void:
	if change_players.size() == 2:
		# access player easily with player id set as node name in setup
		var player0: VisualFormationPlayer = change_players[0]
		var player1: VisualFormationPlayer = change_players[1]
		var index0: int = player0.get_index()
		var index1: int = player1.get_index()
		var parent0: Node = player0.get_parent()
		var parent1: Node = player1.get_parent()
		player0.reparent(parent1)
		player1.reparent(parent0)
		parent0.move_child(player1, index0)
		parent1.move_child(player0, index1)

		team.change_players(change_players[0].player, change_players[1].player)
		change_request.emit()

	else:
		print("error in substitution")
		return

	# _set_players()
	change_players.clear()


func _on_formation_button_item_selected(index: int) -> void:
	_update_formation(index)
	formation_request.emit()


func _on_change_strategy_select_item_selected(index: int) -> void:
	team.formation.change_strategy = index


func _on_tactic_select_offense_item_selected(index: int) -> void:
	team.formation.tactic_offense.tactic = index
	tactic_request.emit()


func _on_tactic_select_marking_item_selected(index: int) -> void:
	team.formation.tactic_defense.marking = index
	tactic_request.emit()


func _on_tactic_select_pressing_item_selected(index: int) -> void:
	team.formation.tactic_defense.pressing = index
	tactic_request.emit()


func _on_tactic_offense_intensity_value_changed(value: float) -> void:
	team.formation.tactic_offense.intensity = int(value)
	tactic_request.emit()
