# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateDefend
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateDefend")


func enter() -> void:
	# move players with no ball into positions
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateDefend.new())


func execute() -> void:
	if owner.team.has_ball:
		set_state(TeamStateAttack.new())
		return

	if not owner.field.clock_running:
		return

	if owner.field.kickin:
		return

	# owner.team.player_chase(owner.team.player_nearest_to_ball([owner.team.players[0]]))


func exit() -> void:
	owner.team.reset_key_players()

