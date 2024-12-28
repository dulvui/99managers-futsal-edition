# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateMachine
extends StateMachine

var player: SimPlayer
var team: SimTeam


func _init(p_field: SimField, p_player: SimPlayer, p_team: SimTeam) -> void:
	super(p_field)
	player = p_player
	team = p_team
	set_state(PlayerStateEnterField.new())


func set_state(p_state: StateMachineState) -> void:
	(p_state as PlayerStateMachineState).owner = self
	super(p_state)
