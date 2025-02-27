# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateFreeKick
extends TeamStateMachineState

var shooting_player: SimPlayer

func _init() -> void:
	super("TeamStateFreeKick")


func enter() -> void:
	if owner.team.has_ball:
		shooting_player = owner.team.players[-1]
		# find best freekick taker currently on field
		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateIdle.new())
			if player.is_goalkeeper:
				continue
			if player.player_res.attributes.technical.free_kick > \
					shooting_player.player_res.attributes.technical.free_kick:
				shooting_player = player

		# move other players forward, except one defender in the back
		var defending_player_found: bool = false
		for player: SimPlayer in owner.team.players:
			if player.is_goalkeeper:
				continue
			if player == shooting_player:
				continue
			if not defending_player_found:
				defending_player_found = true
				player.move_defense_pos()
				continue
			player.move_offense_pos()

		# make player shoot
		shooting_player.set_state(PlayerStateFreeKick.new())
	else:
		# let some players build a wall
		var players_in_wall: int = 1

		# move wall 5m away and between ball and goal
		var wall_position: Vector2 = owner.field.ball.pos
		if owner.team.left_half:
			wall_position += wall_position.direction_to(owner.field.goals.left) * owner.field.PIXEL_FACTOR * 5
		else:
			wall_position += wall_position.direction_to(owner.field.goals.right) * owner.field.PIXEL_FACTOR * 5

		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateIdle.new())
			if player.is_goalkeeper:
				continue
			if players_in_wall > 0:
				players_in_wall -= 1
				player.set_destination(wall_position)
				continue

			player.move_defense_pos()


func execute() -> void:
	if owner.team.has_ball:
		if shooting_player != null:
			# wait for shooting player to shoot
			if shooting_player.state_machine.state is PlayerStateFreeKick:
				return
			owner.team.set_state(TeamStateAttack.new())
			owner.team.team_opponents.set_state(TeamStateDefend.new())


