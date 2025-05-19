# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Person
extends JSONResource

enum Role {
	UNEMPLOYED,
	PLAYER,
	MANAGER,
	PRESIDENT,
	SCOUT,
	AGENT,
	MEDICAL,
}

@export var id: int
@export var nation: String
@export var name: String
@export var surname: String
@export var birth_date: Dictionary
@export var prestige: float
@export var role: Role
@export var skintone: String
@export var haircolor: String
@export var eyecolor: String


func _init(
	p_role: Role = Role.UNEMPLOYED,
	p_id: int = -1,
	p_nation: String = "",
	p_name: String = "",
	p_surname: String = "",
	p_birth_date: Dictionary = {},
	p_prestige: float = 0.0,
	p_skintone: String = "",
	p_haircolor: String = "",
	p_eyecolor: String = "",
) -> void:
	role = p_role
	id = p_id
	nation = p_nation
	name = p_name
	surname = p_surname
	birth_date = p_birth_date
	prestige = p_prestige
	skintone = p_skintone
	haircolor = p_haircolor
	eyecolor = p_eyecolor


func set_id() -> void:
	id = IdUtil.next_id(IdUtil.Types.PERSON)


func get_full_name() -> String:
	return name + " " + surname


func get_age(date: Dictionary) -> int:
	var years: int = date.year - birth_date.year - 1
	if date.month > birth_date.month:
		return years + 1
	if date.month == birth_date.month and date.day >= birth_date.day:
		return years + 1
	return years

