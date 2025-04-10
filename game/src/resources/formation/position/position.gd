# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Position
extends JSONResource

# 9X9 grid + goalkeeper
enum Type {
	G,
	DL,
	DC,
	DR,
	C,
	WL,
	WR,
	PL,
	PC,
	PR,
	UNDEFINED
}

@export var main: Type
@export var alternatives: Array[Type]

static var defense_types: Array[Type] = [Type.DL, Type.DC, Type.DR]
static var center_types: Array[Type] = [Type.WL, Type.C, Type.WR]
static var attack_types: Array[Type] = [Type.PL, Type.PC, Type.PR]


func _init(
	p_main: Type = Type.UNDEFINED,
	p_alternatives: Array[Type] = [],
) -> void:
	main = p_main
	alternatives = p_alternatives


func match_factor(p_type: Type) -> float:
	# propably a mock player
	if main == null:
		return 0

	if main == p_type or main in alternatives:
		return 1
	# same sector
	if main in attack_types and p_type in attack_types:
		return 0.75
	if main in center_types and p_type in center_types:
		return 0.75
	if main in defense_types and p_type in defense_types:
		return 0.75
	# nearly same sector
	if main in attack_types and p_type in center_types:
		return 0.5
	if main in center_types and p_type in attack_types:
		return 0.5
	if main in defense_types and p_type in center_types:
		return 0.5
	if main in center_types and p_type in defense_types:
		return 0.5
	# not same sector
	if main in attack_types and p_type in defense_types:
		return 0.25
	if main in defense_types and p_type in attack_types:
		return 0.25
	return 0

