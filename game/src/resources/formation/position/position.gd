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
@export var variations: Array[PositionVariation]

static var defense_types: Array[Type] = [Type.DL, Type.DC, Type.DR]
static var center_types: Array[Type] = [Type.WL, Type.C, Type.WR]
static var attack_types: Array[Type] = [Type.PL, Type.PC, Type.PR]


func _init(
	p_name: String = "",
	p_description: String = "",
	p_coordinates: Vector2 = Vector2.ZERO,
	p_type: Type = Type.G,
	p_variations: Array[PositionVariation] = []
) -> void:
	name = p_name
	description = p_description
	coordinates = p_coordinates
	type = p_type
	variations = p_variations


func random_variations() -> void:
	var base: Array
	match type:
		Type.G:
			base = PositionVariation.G.keys()
		Type.DL, Type.DC, Type.DR:
			base = PositionVariation.D.keys()
		Type.C:
			base = PositionVariation.C.keys()
		Type.WL, Type.WR:
			base = PositionVariation.W.keys()
		Type.PR, Type.PC, Type.PL:
			base = PositionVariation.P.keys()

	var size: int = base.size()
	for i: int in RngUtil.rng.randi_range(1, size):
		var random_pick: int = RngUtil.rng.randi_range(0, base.size() - 1)
		var variation: PositionVariation = PositionVariation.new()
		variation.type = base[random_pick]
		base.remove_at(random_pick)

		if i == 1:
			variation.confidence = 5
		else:
			variation.confidence = RngUtil.rng.randi_range(1, 4)

		variations.append(variation)

	#print(variations)


func match_factor(position: Position) -> float:
	var p_type : Type = position.type
	
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
