# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateDefend
extends TeamStateMachineState


func enter() -> void:
	# move players with no ball into positions
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateStartPosition.new("PlayerStateStartPosition"))


func execute() -> void:
	if owner.team.has_ball:
		set_state(TeamStateAttack.new("TeamStateAttack"))

	owner.team.chase_ball()
