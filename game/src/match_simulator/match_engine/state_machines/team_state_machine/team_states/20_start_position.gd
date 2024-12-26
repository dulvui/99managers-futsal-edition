# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateStartPositions
extends TeamStateMachineState


const WAIT: int = Const.TICKS_PER_SECOND * 2

var ticks: int


func enter() -> void:
	ticks = 0

	# move players to start positions
	for player: SimPlayer in owner.team.players:
		var start_position: Vector2 = player.start_pos
		# add some noise
		start_position.x += RngUtil.match_noise(5, 5)
		start_position.y += RngUtil.match_noise(5, 5)

		player.set_destination(start_position)


func execute() -> void:
	# move players to positon
	# if reached
	for player: SimPlayer in owner.team.players:
		if not player.destination_reached():
			return
	
	# wait a bit in center, before kick off
	ticks += 1
	if ticks == WAIT:
		set_state(TeamStateKickoff.new())

