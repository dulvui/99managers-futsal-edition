# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateGoal
extends TeamStateMachineState


const MAX = Const.TICKS_PER_SECOND * 8
const MIN = Const.TICKS_PER_SECOND * 2

var celebration_time: int


func _init() -> void:
	super("TeamStateGoal")


func enter() -> void:
	# value could be adjusted on how important goal is
	if owner.team.has_ball:
		celebration_time = RngUtil.match_rng.randi_range(MIN, MAX)

		for player: SimPlayer in owner.team.players:
			player.set_state(PlayerStateGoal.new())


func execute() -> void:
	if owner.team.has_ball:
		# celebrate
		celebration_time -= 1
		if celebration_time < 0:
			set_state(TeamStateKickoff.new())
	else:
		# players are sad
		set_state(TeamStateKickoff.new())
