# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateFindBestPass
extends PlayerStateMachineState

const WAIT: int = 3
const MAX_PASS_SEARCH_ATTEMPTS: int = 4

var ticks: int
var pass_search_attempts: int


func _init() -> void:
	super("PlayerStateFindBestPass")
	ticks = 0
	pass_search_attempts = 0


func enter() -> void:
	owner.player.set_destination(owner.field.ball.pos)


func execute() -> void:
	if not owner.player.destination_reached():
		return

	ticks += 1
	if ticks < WAIT:
		return

	# find best pass
	var pass_force: float = 15
	var best_player: SimPlayer = owner.team.find_best_pass(owner.player, pass_force)
	if best_player == null:
		pass_search_attempts += 1

		if pass_search_attempts < MAX_PASS_SEARCH_ATTEMPTS:
			# still searching best player
			return

		# force pass by passing attacker
		best_player = owner.team.players[-1]

	owner.team.player_receive_ball(best_player)
	var pass_direction: Vector2 = owner.field.ball.pos.direction_to(best_player.pos)
	owner.field.ball.impulse(pass_direction, pass_force)
	owner.team.stats.passes += 1

	if owner.player.is_goalkeeper:
		set_state(PlayerStateGoalkeeperFollowBall.new())
	else:
		set_state(PlayerStateAttack.new())

