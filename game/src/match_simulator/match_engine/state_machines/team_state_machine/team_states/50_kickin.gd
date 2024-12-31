# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickin
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateKickin")


func enter() -> void:
	if owner.team.has_ball:
		owner.team.player_nearest_to_ball.set_destination(owner.field.ball.pos)
		owner.team.player_control = owner.team.player_nearest_to_ball


func execute() -> void:
	if owner.team.has_ball:
		if owner.team.player_control.destination_reached():
			owner.team.player_control.set_state(PlayerStateAttackPass.new())
			set_state(TeamStateAttack.new())
			owner.field.clock_running = true
			return
	else:
		set_state(TeamStateDefend.new())
