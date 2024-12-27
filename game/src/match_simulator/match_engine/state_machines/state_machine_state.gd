# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StateMachineState


func execute() -> void:
	print("execute")
	pass


func enter() -> void:
	print("enter")
	pass


func exit() -> void:
	print("exit")
	pass


func set_state(_next_state: StateMachineState) -> void:
	print("set state")
	pass

