# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickoff
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateKickoff")


func enter() -> void:
	owner.field.kickoff = true
	owner.team.ready_for_kickoff = false

	# move player for kick off to center
	if owner.team.has_ball:
		# move ball to center
		owner.ball.set_pos(owner.field.center)
		# move control player to kick off position
		var player: SimPlayer = owner.team.players[-1]
		owner.team.player_control(player)

		# set destination a bit afer the centre
		# so player looks towards his team and can pass the ball
		player.set_destination(owner.field.center, 20, 18)

		player.set_state(PlayerStateIdle.new())


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
		owner.team.team_opponents.set_state(TeamStateDefend.new())
		set_state(TeamStateAttack.new())


func exit() -> void:
	owner.field.kickoff = false


func kickoff_pass() -> void:
	owner.team.stats.passes += 1
	var random_player: int = owner.rng.randi_range(1, 3)

	var player: SimPlayer = owner.team.players[random_player]
	owner.team.player_receive_ball(player)
	var direction: Vector2 = owner.ball.pos.direction_to(player.pos)
	owner.ball.impulse(direction, 20)

