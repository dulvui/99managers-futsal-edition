# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateKickoff
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateKickoff")


func execute() -> void:
	if owner.field.clock_running:
		set_state(PlayerStateWait.new())
