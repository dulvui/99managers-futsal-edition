# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")


func execute() -> void:
	owner.player.set_destination(owner.ball.pos, 10)

	# check foul
	if not owner.team.has_ball:
		var controlling_player: SimPlayer = owner.team.team_opponents.player_control()
		if owner.player.collides(controlling_player):
			# TODO take aggressive and other attributes into account
			owner.team.stats.tackles += 1
			if owner.rng.rand100(98):
				# TODO check yellow/red card
				owner.team.foul.emit(controlling_player.pos)
				return

			owner.team.stats.tackles_success += 1

	if owner.player.is_touching_ball():
		owner.player.gain_control()

