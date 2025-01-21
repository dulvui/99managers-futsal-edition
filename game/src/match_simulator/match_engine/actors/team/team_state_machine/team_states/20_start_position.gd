# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateStartPositions
extends TeamStateMachineState


const WAIT: int = Const.TICKS_PER_SECOND * 1

var ticks: int


func _init() -> void:
	super("TeamStateStartPositions")


func enter() -> void:
	owner.team.ready_for_kickoff = false

	# move ball to center
	owner.field.ball.set_pos(owner.field.center)

	ticks = 0

	# move players to start positions
	for player: SimPlayer in owner.players:
		player.move_defense_pos()


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

