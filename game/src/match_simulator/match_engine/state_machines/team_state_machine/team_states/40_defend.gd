# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateDefend
extends TeamStateMachineState


func enter() -> void:
	# move players with no ball into positions
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateStartPosition.new())


func execute() -> void:
	if owner.team.has_ball:
		set_state(TeamStateAttack.new())
	
	if not owner.team.player_nearest_to_ball.state_machine.state is PlayerStateChaseBall:
		owner.team.player_nearest_to_ball.set_state(PlayerStateChaseBall.new())
