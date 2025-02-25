# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Technical
extends JSONResource

# all attributes self describing
@export var crossing: int
@export var passing: int
@export var long_passing: int
@export var tackling: int
@export var heading: int
@export var interception: int
@export var shooting: int
@export var long_shooting: int
@export var penalty: int
@export var finishing: int
@export var dribbling: int
@export var blocking: int


func _init(
	p_crossing: int = Const.MAX_PRESTIGE,
	p_passing: int = Const.MAX_PRESTIGE,
	p_long_passing: int = Const.MAX_PRESTIGE,
	p_tackling: int = Const.MAX_PRESTIGE,
	p_heading: int = Const.MAX_PRESTIGE,
	p_interception: int = Const.MAX_PRESTIGE,
	p_shooting: int = Const.MAX_PRESTIGE,
	p_long_shooting: int = Const.MAX_PRESTIGE,
	p_penalty: int = Const.MAX_PRESTIGE,
	p_finishing: int = Const.MAX_PRESTIGE,
	p_dribbling: int = Const.MAX_PRESTIGE,
	p_blocking: int = Const.MAX_PRESTIGE,
) -> void:
	crossing = p_crossing
	passing = p_passing
	long_passing = p_long_passing
	tackling = p_tackling
	heading = p_heading
	interception = p_interception
	shooting = p_shooting
	long_shooting = p_long_shooting
	penalty = p_penalty
	finishing = p_finishing
	dribbling = p_dribbling
	blocking = p_blocking


func average() -> float:
	var value: float = 0
	value += crossing
	value += passing
	value += long_passing
	value += tackling
	value += heading
	value += interception
	value += shooting
	value += long_shooting
	value += penalty
	value += finishing
	value += dribbling
	value += blocking
	return value / 12.0
