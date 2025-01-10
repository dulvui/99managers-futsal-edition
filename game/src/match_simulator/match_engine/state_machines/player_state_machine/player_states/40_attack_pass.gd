# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateAttackPass
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateAttackPass")


func execute() -> void:
	owner.team.random_pass()
	owner.team.player_control = owner.team.player_empty
	set_state(PlayerStateWait.new())
	return


func exit() -> void:
	owner.team.player_control = owner.team.player_empty
