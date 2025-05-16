# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerProfile
extends MarginContainer

var player: Player

@onready var custom_tab_container: CustomTabContainer = %CustomTabContainer
@onready var info_view: InfoView = %Info
@onready var attributes_view: AttributesView = %Attributes
@onready var statistics_view: StatisticsView = %Statistics
@onready var contract_view: ContractView = %Contract
@onready var buy_offer: VisualBuyOffer = %Transfer


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		Tests.init_empty_mock_world()
		Global.team = Tests.create_mock_team()
		set_player(Tests.create_mock_player())

	custom_tab_container.setup([tr("Overview"), tr("Transfer"), tr("Contract")])


func set_player(p_player: Player) -> void:
	player = p_player

	info_view.setup(player)
	attributes_view.setup(player)
	statistics_view.setup(player)
	contract_view.setup(player)

	buy_offer.setup(player)

	# always show info view, when setting new player
	info_view.show()

