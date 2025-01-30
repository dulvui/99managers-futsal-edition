# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateEnterField
extends TeamStateMachineState


const WAIT: int = 2

var ticks: int


func _init() -> void:
	super("TeamStateEnterField")


func enter() -> void:
	ticks = 0

	# move players to center bottom, and slightly shifted
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateEnterField.new())


func execute() -> void:
	# move players to positon
	# if reached
	for player: SimPlayer in owner.team.players:
		if not player.destination_reached():
			return
	
	# wait a bit in center, before moving to start positions
	ticks += 1
	if ticks == WAIT:
		set_state(TeamStateStartPositions.new())
		return

