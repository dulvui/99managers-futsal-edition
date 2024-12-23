# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateEnterField
extends TeamStateMachineState


func enter() -> void:
	owner.reset_key_players()


func execute() -> void:
	# move players to positon
	# if reached
	for player: SimPlayer in owner.team.players:
		if not player.state_machine.state is PlayerStateWait:
			return
	
	change_to(TeamStateKickoff.new())

