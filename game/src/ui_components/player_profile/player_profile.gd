# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerProfile
extends VBoxContainer

signal offer(player: Player)

var player: Player

@onready var info_view: InfoView = %INFO
@onready var attributes_view: AttributesView = %ATTRIBUTES
@onready var statistics_view: StatisticsView = %STATISTICS
@onready var contract_view: ContractView = %CONTRACT


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		set_player(Tests.create_mock_player())


func set_player(p_player: Player) -> void:
	player = p_player

	info_view.setup(player)
	attributes_view.setup(player)
	statistics_view.setup(player)
	contract_view.setup(player)
	contract_view.offer_button.pressed.connect(func() -> void: offer.emit(player))

