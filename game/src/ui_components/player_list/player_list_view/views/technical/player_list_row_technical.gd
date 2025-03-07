# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowTechnical
extends PlayerListRow

@onready var crossing: ColorLabel = %Crossing
@onready var passing: ColorLabel = %Passing
@onready var long_passing: ColorLabel = %LongPassing
@onready var tackling: ColorLabel = %Tackling
@onready var heading: ColorLabel = %Heading
@onready var interception: ColorLabel = %Interception
@onready var shooting: ColorLabel = %Shooting
@onready var long_shooting: ColorLabel = %LongShooting
@onready var free_kick: ColorLabel = %FreeKick
@onready var penalty: ColorLabel = %Penalty
@onready var finishing: ColorLabel = %Finishing
@onready var dribbling: ColorLabel = %Dribbling
@onready var blocking: ColorLabel = %Blocking


func setup(player: Player, index: int) -> void:
	super(player, index)
	crossing.setup("Crossing")
	crossing.set_value(player.attributes.technical.crossing)
	passing.setup("Passing")
	passing.set_value(player.attributes.technical.passing)
	long_passing.setup("Long passing")
	long_passing.set_value(player.attributes.technical.long_passing)
	tackling.setup("Tackling")
	tackling.set_value(player.attributes.technical.tackling)
	heading.setup("Heading")
	heading.set_value(player.attributes.technical.heading)
	interception.setup("Interception")
	interception.set_value(player.attributes.technical.interception)
	shooting.setup("Shooting")
	shooting.set_value(player.attributes.technical.shooting)
	long_shooting.setup("Long shooting")
	long_shooting.set_value(player.attributes.technical.long_shooting)
	free_kick.setup("Free kick")
	free_kick.set_value(player.attributes.technical.free_kick)
	penalty.setup("Penalty")
	penalty.set_value(player.attributes.technical.penalty)
	finishing.setup("Finishing")
	finishing.set_value(player.attributes.technical.finishing)
	dribbling.setup("Dribbling")
	dribbling.set_value(player.attributes.technical.dribbling)
	blocking.setup("Blocking")
	blocking.set_value(player.attributes.technical.blocking)
