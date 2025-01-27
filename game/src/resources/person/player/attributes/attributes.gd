# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Attributes
extends JSONResource

# TODO use comments as tooltip/descriptions
# add tag for defense, attack ecc (can have multiple)

@export var goalkeeper: Goalkeeper
@export var mental: Mental
@export var technical: Technical
@export var physical: Physical


func _init(
	p_goalkeeper: Goalkeeper = Goalkeeper.new(),
	p_mental: Mental = Mental.new(),
	p_technical: Technical = Technical.new(),
	p_physical: Physical = Physical.new(),
) -> void:
	goalkeeper = p_goalkeeper
	mental = p_mental
	technical = p_technical
	physical = p_physical


func field_player_average() -> int:
	var value: int = 0
	value += mental.average()
	value += technical.average()
	value += physical.average()
	return value / 3


func goal_keeper_average() -> int:
	return goalkeeper.average()


# get dynamically dictionary of all attributes goalkeeper, mental ecc...
# with all its sub attributes as string array
func get_all_attributes() -> Dictionary:
	var attributes: Dictionary = {}
	for property: Dictionary in get_property_list():
		if property.usage == Const.CUSTOM_PROPERTY_EXPORT:
			var sub_attributes: Array[StringName] = []
			# get sub attributes
			var attribute: Resource = get(property.name)
			for a_property: Dictionary in attribute.get_property_list():
				if a_property.usage == Const.CUSTOM_PROPERTY_EXPORT:
					sub_attributes.append(a_property.name)
			
			attributes[property.name] = sub_attributes

	return attributes
