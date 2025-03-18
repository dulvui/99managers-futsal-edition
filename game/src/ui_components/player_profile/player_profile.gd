# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerProfile
extends MarginContainer

signal offer(player: Player)

var player: Player

@onready var info_view: InfoView = %Info
@onready var attributes_view: AttributesView = %Attributes
@onready var statistics_view: StatisticsView = %Statistics
@onready var contract_view: ContractView = %Contract


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		Global.world = World.new()
		set_player(Tests.create_mock_player())


func set_player(p_player: Player) -> void:
	player = p_player

	info_view.setup(player)
	attributes_view.setup(player)
	statistics_view.setup(player)
	contract_view.setup(player)
	contract_view.offer_button.pressed.connect(func() -> void: offer.emit(player))

	# always show info view, when setting new player
	info_view.show()
