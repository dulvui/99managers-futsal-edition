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

