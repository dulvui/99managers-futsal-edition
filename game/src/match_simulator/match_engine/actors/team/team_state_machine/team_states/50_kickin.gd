# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickin
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateKickin")


func enter() -> void:
	owner.field.kickin = true

	if owner.team.has_ball:
		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateIdle.new())
			if not player.is_goalkeeper:
				player.move_offense_pos()

		owner.team.player_control(owner.team.player_nearest_to_ball())
		owner.team.player_control().set_destination(owner.field.ball.pos)
	else:
		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateIdle.new())
			if not player.is_goalkeeper:
				player.move_defense_pos()


func execute() -> void:
	if owner.team.has_ball:
		if owner.team.player_control().destination_reached():
			pass_ball()
			set_state(TeamStateAttack.new())
			return
	elif not owner.field.kickin:
		set_state(TeamStateDefend.new())


func exit() -> void:
	owner.field.clock_running = true
	owner.field.kickin = false


func pass_ball() -> void:
	# find best pass
	var best_player: SimPlayer
	var player_control: SimPlayer = owner.team.player_control()
	var delta: float = 1.79769e308 # max float
	for player: SimPlayer in owner.team.players:
		if player != player_control:
			var distance: float = player.pos.distance_squared_to(player_control.pos)
			if distance < delta:
				delta = distance
				best_player = player
	
	owner.team.player_receive_ball(best_player)
	owner.field.ball.short_pass(owner.team.player_receive_ball().pos, 20)
	owner.team.stats.passes += 1

