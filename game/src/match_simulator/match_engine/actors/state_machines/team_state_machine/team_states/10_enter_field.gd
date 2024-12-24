# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateEnterField
extends TeamStateMachineState


const WAIT_BEFORE_KICKOFF: int = Const.TICKS_PER_SECOND * 4

var ticks: int


func enter() -> void:
	ticks = 0

	owner.team.reset_key_players()
	
	# move players to center bottom, and slightly shifted
	for player: SimPlayer in owner.team.players:
		var start_position: Vector2 = owner.field.center
		# move down
		start_position.y += owner.field.size.y / 2 + 50
		start_position.y += (owner.team.players.find(player) + 1) * 20
		# move left/right
		if owner.team.left_half:
			start_position.x -= 30
		else:
			start_position.x += 30

		player.set_pos(start_position)

		# move to center, but slightly shifted
		var destination: Vector2 = owner.field.center
		if owner.team.left_half:
			destination.x -= (owner.team.players.find(player) + 1) * 10
		else:
			destination.x += (owner.team.players.find(player) + 1) * 10
		
		player.set_destination(destination)


func execute() -> void:
	# move players to positon
	# if reached
	for player: SimPlayer in owner.team.players:
		if not player.state_machine.state is PlayerStateWait:
			return
	
	# wait a bit in center, before kick off
	ticks += 1
	print(ticks)
	if ticks == WAIT_BEFORE_KICKOFF:
		set_state(TeamStateKickoff.new())

