# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateGoalCelebrate
extends TeamStateMachineState

const MAX: int = 3
const MIN: int = 1

var celebration_time: int


func _init() -> void:
	super("TeamStateGoalCelebrate")


func enter() -> void:
	owner.team.ready_for_kickoff = false

	celebration_time = owner.rng.randi_range(MIN, MAX)

	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStateGoal.new())


func execute() -> void:
	celebration_time -= 1
	if celebration_time < 0:
		set_state(TeamStateStartPositions.new())
