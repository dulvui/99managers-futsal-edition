# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateMachineState
extends StateMachineState

var owner: PlayerStateMachine


func set_state(next_state: StateMachineState) -> void:
	owner.set_state(next_state)
