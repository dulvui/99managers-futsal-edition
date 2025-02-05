# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateReceive
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateReceive")


func enter() -> void:
	# move slowly towards ball
	owner.player.follow(owner.field.ball, 5)


func execute() -> void:
	if owner.player.is_touching_ball():
		owner.field.ball.stop()
		owner.team.player_control(owner.player)
		return

