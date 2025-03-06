# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowGoalkeeper
extends PlayerListRow

# goalkeeper
@onready var reflexes: ColorLabel = %Reflexes
@onready var positioning: ColorLabel = %Positioning
@onready var save_feet: ColorLabel = %SaveFeet
@onready var save_hands: ColorLabel = %SaveHands
@onready var diving: ColorLabel = %Diving


func setup(player: Player) -> void:
	super(player)
	reflexes.setup("Reflexes")
	reflexes.set_value(player.attributes.goalkeeper.reflexes)
	positioning.setup("Positioning")
	positioning.set_value(player.attributes.goalkeeper.positioning)
	save_feet.setup("Save feet")
	save_feet.set_value(player.attributes.goalkeeper.save_feet)
	save_hands.setup("Save hands")
	save_hands.set_value(player.attributes.goalkeeper.save_hands)
	diving.setup("Diving")
	diving.set_value(player.attributes.goalkeeper.diving)
