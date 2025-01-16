# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateDefend
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateDefend")


func enter() -> void:
	# move players with no ball into positions
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateStartPosition.new())


func execute() -> void:
	if owner.team.has_ball:
		set_state(TeamStateAttack.new())
		return

	# make nearest player to ball chase it
	if owner.team.player_nearest_to_ball != null:
		owner.team.player_chase = owner.team.player_nearest_to_ball
		owner.team.player_chase.set_state(PlayerStateChaseBall.new())
	else:
		owner.team.set_nearest_player_to_ball()
		if owner.team.player_nearest_to_ball != owner.team.player_chase:
			owner.team.player_chase = owner.team.player_nearest_to_ball
			owner.team.player_chase.set_state(PlayerStateChaseBall.new())

