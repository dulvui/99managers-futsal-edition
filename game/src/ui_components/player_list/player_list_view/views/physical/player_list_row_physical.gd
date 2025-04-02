# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowPhysical
extends PlayerListRow

@onready var pace: ColorLabel = %Pace
@onready var acceleration: ColorLabel = %Acceleration
@onready var stamina: ColorLabel = %Stamina
@onready var strength: ColorLabel = %Strength
@onready var agility: ColorLabel = %Agility
@onready var jump: ColorLabel = %Jump


func setup(player: Player, index: int) -> void:
	super(player, index)
	pace.setup("Pace")
	pace.set_value(player.attributes.physical.pace)
	acceleration.setup("Acceleration")
	acceleration.set_value(player.attributes.physical.acceleration)
	stamina.setup("Resistance")
	stamina.set_value(player.attributes.physical.resistance)
	strength.setup("Strength")
	strength.set_value(player.attributes.physical.strength)
	agility.setup("Agility")
	agility.set_value(player.attributes.physical.agility)
	jump.setup("Jump")
	jump.set_value(player.attributes.physical.jump)
