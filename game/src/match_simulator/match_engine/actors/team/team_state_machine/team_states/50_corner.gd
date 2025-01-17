# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateCorner
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateCorner")


func enter() -> void:
	# TODO replace with corner tactic chosen player
	owner.team.player_control(owner.team.players[-1])
	
	for player: SimPlayer in owner.players:
		player.set_state(PlayerStateCorner.new())	


func execute() -> void:
	if owner.field.clock_running:
		if owner.team.has_ball:
			set_state(TeamStateAttack.new())
		else:
			set_state(TeamStateDefend.new())

