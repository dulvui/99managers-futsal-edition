# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Continent
extends JSONResource

@export var name: String
@export var nations: Array[Nation]
@export var cup_clubs: Cup
@export var cup_nations: Cup


func _init(
	p_name: String = "",
	p_nations: Array[Nation] = [],
	p_cup_clubs: Cup = Cup.new(),
	p_cup_nations: Cup = Cup.new(),
) -> void:
	name = p_name
	nations = p_nations
	cup_clubs = p_cup_clubs
	cup_nations = p_cup_nations


func from_json(dict: Dictionary) -> void:
	super(dict)

	# continents
	if dict.has("nations"):
		for nation_dict: Dictionary in dict["nations"]:
			var nation: Nation = Nation.new()
			nation.from_json(nation_dict)
			nations.append(nation)


# to check at least one nation of the continent has competitions
func is_competitive() -> bool:
	for nation: Nation in nations:
		if nation.is_competitive():
			return true
	return false


