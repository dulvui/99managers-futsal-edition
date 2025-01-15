# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Staff
extends JSONResource

@export var president: President
@export var scout: Scout
@export var manager: Manager
@export var medical: Medical


func _init(
	p_president: President = President.new(),
	p_scout: Scout = Scout.new(),
	p_manager: Manager = Manager.new(),
) -> void:
	president = p_president
	scout = p_scout
	manager = p_manager


func get_salary() -> int:
	var salary: int = 0

	# dynamically calculate salaries
	for property: Dictionary in get_property_list():
		if property.usage == Const.CUSTOM_PROPERTY:
			var variant: Variant = get(property.name)
			if variant is Person:
				salary += (variant as Person).contract.income
	
	return salary
