# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateCorner
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateCorner")


func enter() -> void:
	owner.field.corner = true

	if owner.team.has_ball:
		owner.team.player_control(owner.team.players[-1])

	for player: SimPlayer in owner.players:
		player.set_state(PlayerStateCorner.new())


func execute() -> void:
	# wait for corner to be kicked
	if owner.field.corner:
		return

	if owner.team.has_ball:
		set_state(TeamStateAttack.new())
	else:
		set_state(TeamStateDefend.new())


func exit() -> void:
	owner.field.corner = false
