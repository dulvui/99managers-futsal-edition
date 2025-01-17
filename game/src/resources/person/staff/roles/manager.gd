# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Manager
extends Person

@export var agent: Agent
@export var formation: Formation


func _init(
	p_agent: Agent = Agent.new(),
	p_formation: Formation = Formation.new(),
) -> void:
	super(Person.Role.MANAGER)
	agent = p_agent
	formation = p_formation