# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperFollowBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperFollowBall")


func execute() -> void:
	# if close to ball, chase it
	if owner.player.pos.distance_squared_to(owner.field.ball.pos) < 5600:
		set_state(PlayerStateChaseBall.new())
		return

	# only follow if in own half
	if owner.player.left_half:
		if owner.field.ball.pos.x < owner.field.size.x / 2:
			owner.player.set_destination(owner.player.left_base + owner.player.left_base.direction_to(owner.field.ball.pos) * 40)
		else:
			owner.player.set_destination(owner.player.left_base)
	else:
		if owner.field.ball.pos.x > owner.field.size.x / 2:
			owner.player.set_destination(owner.player.right_base + owner.player.right_base.direction_to(owner.field.ball.pos) * 40)
		else:
			owner.player.set_destination(owner.player.right_base)

