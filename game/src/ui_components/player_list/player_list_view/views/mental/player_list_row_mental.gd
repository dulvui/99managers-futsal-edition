# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowMental
extends PlayerListRow

@onready var aggression: ColorLabel = %Aggression
@onready var anticipation: ColorLabel = %Anticipation
@onready var decisions: ColorLabel = %Decisions
@onready var concentration: ColorLabel = %Concentration
@onready var vision: ColorLabel = %Vision
@onready var workrate: ColorLabel = %Workrate
@onready var offensive_movement: ColorLabel = %OffensiveMovement
@onready var marking: ColorLabel = %Marking


func setup(player: Player, index: int) -> void:
	super(player, index)
	aggression.setup("Aggression")
	aggression.set_value(player.attributes.mental.aggression)
	anticipation.setup("Anticipation")
	anticipation.set_value(player.attributes.mental.anticipation)
	decisions.setup("Decisions")
	decisions.set_value(player.attributes.mental.decisions)
	concentration.setup("Concentration")
	concentration.set_value(player.attributes.mental.concentration)
	vision.setup("Vision")
	vision.set_value(player.attributes.mental.vision)
	workrate.setup("Workrate")
	workrate.set_value(player.attributes.mental.workrate)
	offensive_movement.setup("OffensiveMovement")
	offensive_movement.set_value(player.attributes.mental.offensive_movement)
	marking.setup("Marking")
	marking.set_value(player.attributes.mental.marking)
