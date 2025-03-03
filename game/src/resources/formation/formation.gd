# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Formation
extends JSONResource

# first value is goalkeeper, second defense etc...
enum Variations {
	F1202,
	F1121,
	F1112,
	F1211,
	F1103,
	F1301,
	F1400,
}

const VARIATIONS_TEXT: Array[String] = [
	"2-2",
	"1-2-1",
	"1-1-2",
	"2-1-1",
	"1-3",
	"3-1",
	"4-0",
]

# defines if automated changes and strategy
enum ChangeStrategy {
	# change players if stamina is low
	AUTO,
	# manual change
	MANUAL,
}

const CHANGE_STRATEGY_TEXT: Array[String] = [
	"Auto",
	"Manual",
]

@export var variation: Variations
@export var change_strategy: ChangeStrategy

@export var goalkeeper: int
@export var defense: int
@export var center: int
@export var attack: int

@export var tactic_defense: TacticDefense
@export var tactic_offense: TacticOffense

@export var positions: Array[Position]


func _init(
	p_variation: Variations = Variations.F1121,
	p_change_strategy: ChangeStrategy = ChangeStrategy.AUTO,
	p_tactic_defense: TacticDefense = TacticDefense.new(),
	p_tactic_offense: TacticOffense = TacticOffense.new(),
	p_positions: Array[Position] = [],
) -> void:
	variation = p_variation
	change_strategy = p_change_strategy
	tactic_defense = p_tactic_defense
	tactic_offense = p_tactic_offense
	positions = p_positions

	set_variation(variation)


func set_variation(p_variation: Variations) -> void:
	variation = p_variation
	var string_values: PackedStringArray = str(Variations.keys()[variation]).split()
	string_values.remove_at(0)  # remove F character from Variations key string

	# extract int values
	var int_values: Array[int] = []
	for value in string_values:
		var int_value: int = int(value)
		int_values.append(int_value)

	goalkeeper = int_values[0]
	defense = int_values[1]
	center = int_values[2]
	attack = int_values[3]


func get_start_pos(field_size: Vector2, index: int, left_side: bool) -> Vector2:
	var pos: Vector2 = Vector2.ZERO

	if index < goalkeeper:
		pos = Vector2(field_size.x / 8, field_size.y / 2)
	elif index < defense + goalkeeper:
		index -= goalkeeper
		pos = Vector2(field_size.x / 4, field_size.y / defense * index)
		# centre position and move slightly towards own half (field_size.x / 20)
		pos += Vector2(-field_size.x / 20, field_size.y / defense / 2)
	elif index < defense + center + goalkeeper:
		index -= goalkeeper + defense
		pos = Vector2(field_size.x / 3, field_size.y / center * index)
		# centre position and move slightly towards own half (field_size.x / 20)
		pos += Vector2(-field_size.x / 20, field_size.y / center / 2)
	else:
		index -= goalkeeper + defense + center
		pos = Vector2(field_size.x / 2, field_size.y / attack * index)
		# centre position and move slightly towards own half (field_size.x / 20)
		pos += Vector2(-field_size.x / 20, field_size.y / attack / 2)

	# invert, if right side
	if not left_side:
		pos = field_size - pos

	return pos


func get_change_strategy_text() -> String:
	match change_strategy:
		ChangeStrategy.AUTO:
			return tr("Auto")
		ChangeStrategy.MANUAL:
			return tr("Manual")
		_:
			return tr("Auto")

