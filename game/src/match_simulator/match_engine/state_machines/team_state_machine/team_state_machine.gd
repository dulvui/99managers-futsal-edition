# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateMachine
extends StateMachine


var team: SimTeam

func _init(p_field: SimField, p_team: SimTeam) -> void:
	super(p_field)
	team = p_team
	set_state(TeamStateEnterField.new("TeamStateEnterField"))


func set_state(p_state: StateMachineState) -> void:
	(p_state as TeamStateMachineState).owner = self
	super(p_state)

