# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StateMachineState


var name: String


func _init(p_name: String) -> void:
	name = p_name


func execute() -> void:
	print("execute " + name)
	pass


func enter() -> void:
	print("enter " + name)
	pass


func exit() -> void:
	print("exit " + name)
	pass


func set_state(p_next_state: StateMachineState) -> void:
	print("set state " + p_next_state.name)
	pass

