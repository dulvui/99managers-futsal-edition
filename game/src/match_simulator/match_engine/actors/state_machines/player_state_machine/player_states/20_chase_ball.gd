# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends StateMachineState


func execute() -> void:
	(owner as PlayerStateMachine).player.set_destination(owner.field.ball.pos)

