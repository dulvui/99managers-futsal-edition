# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateAttack
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateAttack")


func enter() -> void:
	owner.player.move_offense_pos()


func execute() -> void:
	if owner.team.player_control() == owner.player:
		set_state(PlayerStateControl.new())
		return
	elif owner.player.is_goalkeeper:
		set_state(PlayerStateGoalkeeperFollowBall.new())
		return


