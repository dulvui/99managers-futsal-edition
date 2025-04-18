# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Manager
extends StaffMember

@export var formation: Formation


func _init(
	p_formation: Formation = Formation.new(),
) -> void:
	super(Person.Role.MANAGER)
	formation = p_formation

