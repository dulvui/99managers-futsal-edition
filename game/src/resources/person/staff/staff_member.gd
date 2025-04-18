# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StaffMember
extends Person


@export var contract: Contract


func _init(
	p_role: Person.Role = Person.Role.UNEMPLOYED,
	p_contract: Contract = Contract.new(),
) -> void:
	super(p_role)
	contract = p_contract

