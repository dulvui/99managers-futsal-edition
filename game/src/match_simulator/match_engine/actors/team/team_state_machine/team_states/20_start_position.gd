# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateStartPositions
extends TeamStateMachineState


const WAIT: int = Const.STATE_UPDATE_TICKS * 1

var ticks: int


func _init() -> void:
	super("TeamStateStartPositions")


func enter() -> void:
	owner.team.ready_for_kickoff = false

	ticks = 0

	# move players to start positions
	for player: SimPlayer in owner.players:
		player.set_state(PlayerStateStartPosition.new())


func execute() -> void:
	# wait for players to reach start positon
	for player: SimPlayer in owner.players:
		if not player.destination_reached():
			return
	
	# wait a bit before kick off
	ticks += 1
	if ticks < WAIT:
		return

	set_state(TeamStateKickoff.new())

