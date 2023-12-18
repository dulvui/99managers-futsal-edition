# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Resource
class_name Technical

@export var crossing:int
@export var passing:int
@export var long_passing:int
@export var tackling:int
@export var heading:int
@export var interception:int
@export var shooting:int
@export var long_shooting:int
@export var penalty:int
@export var finishing:int
@export var dribbling:int
@export var blocking:int

func _init(
	p_crossing:int = 0,
	p_passing:int = 0,
	p_long_passing:int = 0,
	p_tackling:int = 0,
	p_heading:int = 0,
	p_interception:int = 0,
	p_shooting:int = 0,
	p_long_shooting:int = 0,
	p_penalty:int = 0,
	p_finishing:int = 0,
	p_dribbling:int = 0,
	p_blocking:int = 0,
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
