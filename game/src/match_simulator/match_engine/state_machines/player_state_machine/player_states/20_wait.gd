# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateWait
extends PlayerStateMachineState


func execute() -> void:
	if owner.team.player_control == owner.player:
		# check shoot
		if RngUtil.match(10):
			print("shoot")
			set_state(PlayerStateAttackShoot.new("PlayerStateAttackShoot"))

		# check pass
		if RngUtil.match(90):
			print("pass")
			set_state(PlayerStateAttackPass.new("PlayerStateAttackPass"))

		# check dribble
		print("dribble")
		set_state(PlayerStateAttackDribble.new("PlayerStateAttackDribble"))
	elif owner.team.has_ball:
		# if good positon, become supporting player	
		return
		# print("support")
	else:
		return
		# print("defend")
		# set_state(PlayerStateDefendZone.new("PlayerStateDefendZone"))

