# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateAttack
extends TeamStateMachineState


func execute() -> void:
	# move players with no ball into positions
	change_to(TeamStateGoal.new())
	change_to(TeamStateKickin.new())
	change_to(TeamStateCorner.new())
	change_to(TeamStateFreeKick.new())
	change_to(TeamStatePenalty.new())
