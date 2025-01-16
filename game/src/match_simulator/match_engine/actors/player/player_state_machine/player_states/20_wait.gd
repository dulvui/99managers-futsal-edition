# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateWait
extends PlayerStateMachineState


const PERFECT_SHOOT_DISTANCE_SQUARED: int = pow(80, 2)


func _init() -> void:
	super("PlayerStateWait")


func execute() -> void:
	if owner.team.player_control == owner.player:
		# check shoot
		if should_shoot():
			# print("shoot")
			set_state(PlayerStateAttackShoot.new())
			return

		# check pass
		if RngUtil.match(95):
			# print("pass")
			set_state(PlayerStateAttackPass.new())
			return

		# check dribble
		# print("dribble")
		set_state(PlayerStateAttackPass.new())
		return
	elif owner.player.is_goalkeeper:
		set_state(PlayerStateGoalkeeperFollowBall.new())
		return


func should_shoot() -> bool:
	if owner.team.left_half:
		var distance_squared: float = owner.player.pos.distance_squared_to(owner.field.goals.right)
		if distance_squared < PERFECT_SHOOT_DISTANCE_SQUARED:
			return RngUtil.match(80)
	return RngUtil.match(5)


func should_dribble() -> bool:
	# check opposite players between player and goal
	var opposing_player_count: int = 0
	if owner.team.left_half:
		for player: SimPlayer in owner.team.team_opponents.players:
			if player.pos.x > owner.player.pos.x:
				opposing_player_count += 1
	else:
		for player: SimPlayer in owner.team.team_opponents.players:
			if player.pos.x < owner.player.pos.x:
				opposing_player_count += 1
	
	return RngUtil.match(100 - (opposing_player_count * 20))

