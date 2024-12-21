# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickoff
extends StateMachineState


func enter() -> void:
	# move player to center
	var team: SimTeam = (owner as TeamStateMachine).team
	team.players[-1].set_destination(owner.field.ball.pos)


func execute() -> void:
	var team: SimTeam = (owner as TeamStateMachine).team
	if team.players[-1].destination_reached():
		change_to(TeamStateAttack.new())
	# else
	# change_to(TeamStateDefend.new())
