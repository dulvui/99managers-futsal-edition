# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickin
extends TeamStateMachineState

var kicking_player: SimPlayer


func _init() -> void:
	super("TeamStateKickin")


func enter() -> void:
	owner.field.kickin = true

	if owner.team.has_ball:
		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateIdle.new())
			if not player.is_goalkeeper:
				player.move_offense_pos()

		kicking_player = owner.team.player_nearest_to_ball([owner.team.players[0]])
		# move 15px overrun
		kicking_player.set_destination(owner.ball.pos, 10, 15)
	else:
		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateIdle.new())
			if not player.is_goalkeeper:
				player.move_defense_pos()


func execute() -> void:
	if owner.team.has_ball:
		if kicking_player.destination_reached():
			pass_ball()
			set_state(TeamStateAttack.new())
			owner.team.team_opponents.set_state(TeamStateDefend.new())


func exit() -> void:
	owner.field.kickin = false


func pass_ball() -> void:
	# find best pass
	var best_player: SimPlayer
	var delta: float = 1.79769e308 # max float
	for player: SimPlayer in owner.team.players:
		if player != kicking_player:
			var distance: float = player.pos.distance_squared_to(kicking_player.pos)
			if distance < delta:
				delta = distance
				best_player = player

	owner.team.player_receive_ball(best_player)
	owner.ball.impulse(owner.team.player_receive_ball().pos, 20)
	owner.team.stats.passes += 1

