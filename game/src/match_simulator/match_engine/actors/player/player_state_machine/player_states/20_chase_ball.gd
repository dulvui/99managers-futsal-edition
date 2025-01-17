# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")


func execute() -> void:
	owner.player.set_destination(owner.field.ball.pos)

	if owner.player.is_touching_ball():
		owner.team.player_control = owner.player
		owner.team.interception.emit()
		set_state(PlayerStateWait.new())
		return
	
	# make sure goalkeeper doesn't follow ball too far away from penalty area
	if owner.player.is_goalkeeper:
		if owner.player.left_half:
			if owner.player.pos.distance_squared_to(owner.player.left_base):
				set_state(PlayerStateGoalkeeperFollowBall.new())
				return
		else:
			if owner.player.pos.distance_squared_to(owner.player.right_base):
				set_state(PlayerStateGoalkeeperFollowBall.new())
				return

