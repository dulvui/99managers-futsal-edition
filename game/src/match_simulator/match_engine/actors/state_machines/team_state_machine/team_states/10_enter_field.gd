# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateEnterField
extends StateMachineState


func execute() -> void:
	# move players to positon
	# if reached
	var team: SimTeam = (owner as TeamStateMachine).team
	for player: SimPlayer in team.players:
		if not player.state_machine.state is PlayerStateWait:
			return
	
	change_to(TeamStateKickoff.new())

