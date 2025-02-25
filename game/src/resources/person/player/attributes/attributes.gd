# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Attributes
extends JSONResource

# TODO use comments as tooltip/descriptions
# add tag for defense, attack ecc (can have multiple)

@export var goalkeeper: Goalkeeper
@export var mental: Mental
@export var technical: Technical
@export var physical: Physical


func _init(
	p_goalkeeper: Goalkeeper = Goalkeeper.new(),
	p_mental: Mental = Mental.new(),
	p_technical: Technical = Technical.new(),
	p_physical: Physical = Physical.new(),
) -> void:
	goalkeeper = p_goalkeeper
	mental = p_mental
	technical = p_technical
	physical = p_physical


func field_player_average() -> float:
	var value: float = 0.0
	value += mental.average()
	value += technical.average()
	value += physical.average()
	return value / 3.0


func goal_keeper_average() -> float:
	return goalkeeper.average()
