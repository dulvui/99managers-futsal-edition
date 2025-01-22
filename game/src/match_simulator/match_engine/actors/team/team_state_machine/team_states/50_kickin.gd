# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickin
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateKickin")


func enter() -> void:
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateIdle.new())
	
	if owner.team.has_ball:
		owner.team.player_control(owner.team.player_nearest_to_ball())
		owner.team.player_control().set_destination(owner.field.ball.pos)


func execute() -> void:
	if owner.team.has_ball:
		if owner.team.player_control().destination_reached():
			owner.team.player_control().set_state(PlayerStatePass.new())
			set_state(TeamStateAttack.new())
			return
	elif owner.field.clock_running:
		set_state(TeamStateDefend.new())


func exit() -> void:
	owner.field.clock_running = true
