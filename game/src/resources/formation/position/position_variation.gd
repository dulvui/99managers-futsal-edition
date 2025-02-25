# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PositionVariation
extends JSONResource

enum G {
	NORMAL,
	FLYING,
}

enum D {
	NORMAL,
	STAY_BACK,
	ATTACK,
}

enum C {
	NORMAL,
	STAY_BACK,
	PLAYMAKER,
	ATTACK,
}

enum W {
	NORMAL,
	STAY_BACK,
	FULL,
	ATTACK,
}

enum P {
	NORMAL,
	PIVOT,
	DYNAMIC,
}

@export var name: String
@export var description: String
@export var coordinates: Vector2
# 0, if player can't play position
@export var confidence: int
@export var type: String


func _init(
	p_name: String = "",
	p_description: String = "",
	p_coordinates: Vector2 = Vector2.ZERO,
	p_confidence: int = 0,
	p_type: String = "",
) -> void:
	name = p_name
	description = p_description
	coordinates = p_coordinates
	confidence = p_confidence
	type = p_type


