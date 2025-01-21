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
		else:
			player.set_state(PlayerStateAttack.new())


func execute() -> void:
	if not owner.team.has_ball:
		set_state(TeamStateDefend.new())
		return

	# make player closest to best supporting position supporting player
	# and move it there
	if owner.team.player_support == null or owner.team.player_support == owner.team.player_control:
		# find nearest player to best supporting sector
		var sector_position: Vector2 = owner.field.calculator.best_sector.position
		var player: SimPlayer = owner.team.find_nearest_player_to(sector_position, [owner.team.player_control()])
		player.set_state(PlayerStateSupport.new())
		player.set_destination(sector_position)
		owner.team.player_support(player)



	# move players with no ball into positions
	# set_state(TeamStateGoal.new())
	# set_state(TeamStateKickin.new())
	# set_state(TeamStateCorner.new())
	# set_state(TeamStateFreeKick.new())
	# set_state(TeamStatePenalty.new())


func exit() -> void:
	owner.team.reset_key_players()
