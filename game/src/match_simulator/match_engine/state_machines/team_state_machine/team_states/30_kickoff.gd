# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickoff
extends TeamStateMachineState


func enter() -> void:
	# move player for kick off to center
	if owner.team.has_ball:
		owner.team.player_control = owner.team.players[-1]
		owner.team.player_control.set_destination(owner.field.ball.pos)


func execute() -> void:
	if owner.team.has_ball:
		if owner.team.player_control.destination_reached():
			# start match time
			owner.field.clock_running = true
			# pass ball
			owner.team.kickoff_pass()
			set_state(TeamStateAttack.new())
	# when time started, defend
	elif owner.field.clock_running:
		set_state(TeamStateDefend.new())
