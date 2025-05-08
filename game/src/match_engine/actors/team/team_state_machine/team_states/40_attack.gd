# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateAttack
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateAttack")


func enter() -> void:
	# set player states
	for player: SimPlayer in owner.team.players:
		if player.is_goalkeeper:
			player.set_state(PlayerStateGoalkeeperFollowBall.new())
		# make sure not to chang player to attack that is receiving a ball from kickoff
		if player.state_machine.state is PlayerStateReceive:
			continue
		# and not already controlling player
		if player.state_machine.state is PlayerStateControl:
			continue
		player.set_state(PlayerStateAttack.new())

	# make player closest to best supporting position supporting player
	# and move it there
	# var sector_position: Vector2 = owner.field.calculator.best_shoot_sector.position
	# var player: SimPlayer = owner.team.find_nearest_player_to(
	# 	sector_position, [owner.team.player_control(), owner.team.player_receive_ball()]
	# )
	# # TODO: use tactics to define supporging players amount
	# # and if picking best shoot or best bass sector
	# player.set_destination(sector_position)
	# owner.team.player_support(player)


func exit() -> void:
	owner.team.reset_key_players()

