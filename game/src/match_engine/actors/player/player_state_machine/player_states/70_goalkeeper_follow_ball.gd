# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperFollowBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperFollowBall")


func execute() -> void:
	if owner.player.is_touching_ball():
		owner.player.gain_control()
		return

	# if own team has ball, just move to defense position
	if owner.team.has_ball:
		owner.player.move_defense_pos()
		return

	# only follow if in own half
	if owner.player.left_half:
		if owner.ball.pos.x < owner.field.size.x / 2:
			owner.player.set_destination(
				(
					owner.player.left_base
					+ owner.player.left_base.direction_to(owner.ball.pos) * 40
				)
			)
		else:
			owner.player.set_destination(owner.player.left_base)
	else:
		if owner.ball.pos.x > owner.field.size.x / 2:
			owner.player.set_destination(
				(
					owner.player.right_base
					+ owner.player.right_base.direction_to(owner.ball.pos) * 40
				)
			)
		else:
			owner.player.set_destination(owner.player.right_base)

