# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickoff
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateKickoff")


func enter() -> void:
	owner.team.ready_for_kickoff = false

	# move player for kick off to center
	if owner.team.has_ball:
		# move ball to center
		owner.field.ball.set_pos(owner.field.center)
		# move control player to kick off position
		owner.team.player_control(owner.team.players[-1])
		owner.team.player_control().set_destination(owner.field.ball.pos, 20)
		owner.team.player_control().set_state(PlayerStateIdle.new())


func execute() -> void:
	# wait for players to reach destination
	if not owner.team.ready_for_kickoff:
		for player: SimPlayer in owner.team.players:
			if not player.destination_reached():
				return

		owner.team.ready_for_kickoff = true

	# wait for opponents to be ready
	if not owner.team.team_opponents.ready_for_kickoff:
		return

	if owner.team.has_ball:
		# pass ball
		kickoff_pass()
		set_state(TeamStateAttack.new())
		return
	# when time started, defend
	elif owner.field.clock_running:
		set_state(TeamStateDefend.new())
		return


func exit() -> void:
	owner.field.clock_running = true


func kickoff_pass() -> void:
	owner.team.stats.passes += 1
	var random_player: int = owner.rng.randi_range(1, 3)

	owner.team.player_receive_ball(owner.team.players[random_player])
	owner.field.ball.short_pass(owner.team.player_receive_ball().pos, 20)
