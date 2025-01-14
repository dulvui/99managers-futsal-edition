# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateCorner
extends TeamStateMachineState


var wait_counter: int
var wait: int


func _init() -> void:
	super("TeamStateCorner")
	wait_counter = 0


func enter() -> void:
	for player: SimPlayer in owner.players:
		player.set_state(PlayerStateCorner.new())
	
	if owner.team.has_ball:
		owner.team.player_control = owner.players[-1]
		owner.players[-1].set_destination(owner.field.ball.pos)
	
	wait = RngUtil.match_rng.randi_range(1, 5)


func execute() -> void:
	if owner.team.has_ball:
		if owner.team.player_control.destination_reached():
			wait_counter += 1
			if wait_counter >= wait:
				owner.team.player_control.set_state(PlayerStateAttackPass.new())
				set_state(TeamStateAttack.new())
	elif owner.field.clock_running:
		set_state(TeamStateDefend.new())

