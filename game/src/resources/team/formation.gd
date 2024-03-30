# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Resource
class_name Formation

# first value is goalkeeper, seoncd defense etc...
enum Variations {
	F1202,
	F1121,
	F1112,
	F1211,
	F1103,
	F1301,
	F1400,
	# TODO add power play
	#F0023,
	#F0032,
	#F0014,
	#F0113
}

@export var variation_defense:int
@export var variation_offense:int

@export var goalkeeper:int
@export var defense:int
@export var center:int
@export var attack:int

@export var tactic_defense:TacticDefense
@export var tactic_offense:TacticOffense

func _init(
	p_variation_defense:Variations = Variations.F1202,
	p_variation_offense:Variations = Variations.F1121,
	p_tactic_defense:TacticDefense = TacticDefense.new(),
	p_tactic_offense:TacticOffense = TacticOffense.new(),
) -> void:
	variation_defense = p_variation_defense
	variation_offense = p_variation_offense
	set_variation(variation_offense)

	tactic_defense = p_tactic_defense
	tactic_offense = p_tactic_offense

# TODO also add defense
func set_variation(p_variation_offense:Variations) -> void:
	variation_offense = p_variation_offense
	
	var string_values:PackedStringArray = Variations.keys()[variation_offense].split()
	string_values.remove_at(0) # remove F
	
	# extract int values
	var int_values:Array[int] = []
	for value in string_values:
		var int_value:int = int(value)
		int_values.append(int_value)
	
	goalkeeper = int_values[0]
	defense = int_values[1]
	center = int_values[2]
	attack = int_values[3]
	
func get_field_pos(field_size:Vector2, index:int, left_side:bool) -> Vector2:
	var pos:Vector2 = Vector2.ZERO
	
	if index < defense:
		pos = Vector2(field_size.x / 4, field_size.y / defense * index)
		# centre position and move slightli towards own half (field_size.x / 20)
		pos += Vector2(-field_size.x / 20, field_size.y / defense / 2)
	elif index < defense + center:
		index -= defense
		pos = Vector2(field_size.x / 3, field_size.y / center * index)
		# centre position and move slightli towards own half (field_size.x / 20)
		pos += Vector2(-field_size.x / 20, field_size.y / center / 2)
	else:
		index -= defense + center
		pos = Vector2(field_size.x / 2, field_size.y / attack * index)
		# centre position and move slightli towards own half (field_size.x / 20)
		pos += Vector2(-field_size.x / 20, field_size.y / attack / 2)
	

	# invert, if right side
	if not left_side:
		pos = field_size - pos
	
	return pos
