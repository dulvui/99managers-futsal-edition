# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperBall
extends PlayerStateMachineState

const WAIT: int = 3

var ticks: int


func _init() -> void:
	super("PlayerStateGoalkeeperBall")
	ticks = 0


func enter() -> void:
	owner.player.set_destination(owner.field.ball.pos)


func execute() -> void:
	if not owner.player.destination_reached():
		return

	ticks += 1
	if ticks < WAIT:
		return

	# find best pass
	var best_player: SimPlayer
	var delta: float = 1.79769e308  # max float
	for player: SimPlayer in owner.team.players:
		if player != owner.player:
			var distance: float = player.pos.distance_squared_to(owner.player.pos)
			if distance < delta:
				delta = distance
				best_player = player

	owner.team.player_receive_ball(best_player)
	owner.field.ball.impulse(owner.team.player_receive_ball().pos, 40)
	owner.team.stats.passes += 1

	set_state(PlayerStateIdle.new())


func exit() -> void:
	owner.field.goalkeeper_ball = false
