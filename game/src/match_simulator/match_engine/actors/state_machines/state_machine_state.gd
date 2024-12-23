# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StateMachineState


func execute() -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func set_state(_next_state: StateMachineState) -> void:
	pass

