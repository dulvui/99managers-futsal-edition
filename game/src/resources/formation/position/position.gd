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
}

@export var name: String
@export var description: String
@export var coordinates: Vector2
@export var type: Type

static var defense_types: Array[Type] = [Type.DL, Type.DC, Type.DR]
static var center_types: Array[Type] = [Type.WL, Type.C, Type.WR]
static var attack_types: Array[Type] = [Type.PL, Type.PC, Type.PR]


func _init(
	p_name: String = "",
	p_description: String = "",
	p_coordinates: Vector2 = Vector2.ZERO,
	p_type: Type = Type.G,
) -> void:
	name = p_name
	description = p_description
	coordinates = p_coordinates
	type = p_type


func match_factor(position: Position) -> float:
	var p_type: Type = position.type

	# propably a mock player
	if type == null:
		return 0

	if type == p_type:
		return 1
	# same sector
	if type in attack_types and p_type in attack_types:
		return 0.75
	if type in center_types and p_type in center_types:
		return 0.75
	if type in defense_types and p_type in defense_types:
		return 0.75
	# nearly same sector
	if type in attack_types and p_type in center_types:
		return 0.5
	if type in center_types and p_type in attack_types:
		return 0.5
	if type in defense_types and p_type in center_types:
		return 0.5
	if type in center_types and p_type in defense_types:
		return 0.5
	# not same sector
	if type in attack_types and p_type in defense_types:
		return 0.25
	if type in defense_types and p_type in attack_types:
		return 0.25
	return 0


func get_type_text(p_type: Type = type) -> String:
	match p_type:
		Type.G:
			return tr("G")
		Type.DL:
			return tr("DL")
		Type.DC:
			return tr("DC")
		Type.DR:
			return tr("DR")
		Type.C:
			return tr("C")
		Type.WL:
			return tr("WL")
		Type.WR:
			return tr("WR")
		Type.PL:
			return tr("PL")
		Type.PC:
			return tr("PC")
		Type.PR:
			return tr("PR")
	return ""
