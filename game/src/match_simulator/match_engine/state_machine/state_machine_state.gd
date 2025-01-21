# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StateMachineState


var name: String
# dominant states can't be overwritten by other states
# only by exit()
var dominant: bool


func _init(p_name: String, p_dominant: bool = false) -> void:
	name = p_name
	dominant = p_dominant


func execute() -> void:
	# print("execute " + name)
	pass


func enter() -> void:
	# print("enter " + name)
	pass


func exit() -> void:
	# print("exit " + name)
	pass


func set_state(_p_next_state: StateMachineState) -> void:
	# print("set state " + p_next_state.name)
	pass

