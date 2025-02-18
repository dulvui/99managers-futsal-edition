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
@export var prestige: int  # 1-20
@export var role: Role
@export var contract: Contract
@export var skintone: String
@export var haircolor: String
@export var eyecolor: String


func _init(
	p_role: Role = Role.UNEMPLOYED,
	p_id: int = -1,
	p_nation: String = "",
	p_name: String = "",
	p_surname: String = "",
	p_birth_date: Dictionary = Time.get_datetime_dict_from_system(),
	p_prestige: int = 10,
	p_contract: Contract = Contract.new(),
	p_skintone: String = Color.SALMON.to_html(true),
	p_haircolor: String = Color.BROWN.to_html(true),
	p_eyecolor: String = Color.BLACK.to_html(true),
) -> void:
	role = p_role
	id = p_id
	nation = p_nation
	name = p_name
	surname = p_surname
	birth_date = p_birth_date
	prestige = p_prestige
	contract = p_contract
	skintone = p_skintone
	haircolor = p_haircolor
	eyecolor = p_eyecolor


func set_id() -> void:
	id = IdUtil.next_id(IdUtil.Types.PERSON)


func get_full_name() -> String:
	return name + " " + surname


func get_age(date: Dictionary) -> int:
	return date.year - birth_date.year


