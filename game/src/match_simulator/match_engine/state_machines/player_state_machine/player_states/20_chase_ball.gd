# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func execute() -> void:
	owner.player.set_destination(owner.field.ball.pos)

	if owner.player.is_touching_ball():
		owner.team.interception.emit()

