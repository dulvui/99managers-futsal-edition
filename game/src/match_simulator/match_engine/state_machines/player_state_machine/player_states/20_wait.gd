# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateWait
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateWait")


func execute() -> void:
	if owner.team.player_control == owner.player:
		if RngUtil.match(10):
			print("shoot")
			set_state(PlayerStateAttackShoot.new())
			return

		if RngUtil.match(40):
			print("dribble")
			set_state(PlayerStateAttackDribble.new())
			return

		print("pass")
		set_state(PlayerStateAttackPass.new())
		return
	elif owner.team.has_ball:
		# if good positon, become supporting player	
		return
		# print("support")
	else:
		return
		# print("defend")
		# set_state(PlayerStateDefendZone.new())

