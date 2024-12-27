# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateEnterField
extends TeamStateMachineState


const WAIT: int = Const.TICKS_PER_SECOND * 1

var ticks: int


func enter() -> void:
	print("enter field")
	ticks = 0

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


		# move to center, but slightly shifted
		var destination: Vector2 = owner.field.center
		if owner.team.left_half:
			destination.x -= (owner.team.players.find(player) + 1) * 30
		else:
			destination.x += (owner.team.players.find(player) + 1) * 30
		
		# add some noise
		start_position.x += RngUtil.match_noise(5, 5)
		start_position.y += RngUtil.match_noise(5, 5)
		destination.x += RngUtil.match_noise(5, 5)
		destination.y += RngUtil.match_noise(5, 5)

		player.set_pos(start_position)
		player.set_destination(destination)
	
		# look towards destination
		player.head_look_direction = destination



func execute() -> void:
	# move players to positon
	# if reached
	for player: SimPlayer in owner.team.players:
		if not player.destination_reached():
			return
		# look down
		player.head_look_direction = player.pos + Vector2(0, 100)
	
	# wait a bit in center, before moving to start positions
	ticks += 1
	if ticks == WAIT:
		print("enter field done")
		set_state(TeamStateStartPositions.new())


func exit() -> void:
	# reset head look direction
	for player: SimPlayer in owner.team.players:
		player.head_look_direction = Vector2.ZERO
