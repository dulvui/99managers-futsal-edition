# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Goalkeeper
extends JSONResource

# ticks/time needed to react to shot
@export var reflexes: int
# probability of choosing potentially best position in goal
@export var positioning: int
# saving with feet
@export var save_feet: int
# saving with hands
@export var save_hands: int
# timing and distance of dives
@export var diving: int


func _init(
	p_reflexes: int = 0,
	p_positioning: int = 0,
	p_save_feet: int = 0,
	p_save_hands: int = 0,
	p_diving: int = 0,
) -> void:
	reflexes = p_reflexes
	positioning = p_positioning
	save_feet = p_save_feet
	save_hands = p_save_hands
	diving = p_diving


func sum() -> int:
	var value: int = 0
	value += reflexes
	value += positioning
	value += save_feet
	value += save_hands
	value += diving
	return value


func average() -> float:
	return sum() / 5.0

