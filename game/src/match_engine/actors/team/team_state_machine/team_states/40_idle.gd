# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateIdle
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateIdle")


func enter() -> void:
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateIdle.new())

# just waiting...

