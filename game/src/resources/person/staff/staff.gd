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
	p_medical: Medical = Medical.new(),
) -> void:
	president = p_president
	scout = p_scout
	manager = p_manager
	medical = p_medical


func get_salary() -> int:
	var salary: int = 0

	salary += scout.contract.income
	salary += manager.contract.income
	salary += medical.contract.income

	return salary

