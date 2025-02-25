# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Mental
extends JSONResource

# TODO use comments as tooltip/descriptions
# add tag for defense, attack ecc (can have multiple)

# how often/strong player tackles
@export var aggression: int
# interception movements, if implemented
@export var anticipation: int
# probability of taking best next move/action
@export var decisions: int
# reducing with stamina probability of taking best next move/action
@export var concentration: int
# seek pass distance
@export var vision: int
# intensity of marking and attack movements
@export var workrate: int
# probability of choosing best support spot
@export var offensive_movement: int
# probability of choosing best marking spot
@export var marking: int


func _init(
	p_aggression: int = Const.MAX_PRESTIGE,
	p_anticipation: int = Const.MAX_PRESTIGE,
	p_decisions: int = Const.MAX_PRESTIGE,
	p_concentration: int = Const.MAX_PRESTIGE,
	p_vision: int = Const.MAX_PRESTIGE,
	p_workrate: int = Const.MAX_PRESTIGE,
	p_marking: int = Const.MAX_PRESTIGE,
) -> void:
	aggression = p_aggression
	anticipation = p_anticipation
	decisions = p_decisions
	concentration = p_concentration
	vision = p_vision
	workrate = p_workrate
	marking = p_marking


func average() -> float:
	var value: int = 0
	value += aggression
	value += anticipation
	value += decisions
	value += concentration
	value += vision
	value += workrate
	value += marking
	return value / 7.0
