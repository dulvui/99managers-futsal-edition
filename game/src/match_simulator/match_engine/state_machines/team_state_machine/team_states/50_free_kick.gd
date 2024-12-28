# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateFreeKick
extends TeamStateMachineState
	

func execute() -> void:
	# if team has ball
		# move player to free kick
		# shoot
	# else
		# some players make wall
	set_state(TeamStateGoal.new("TeamStateGoal"))
	set_state(TeamStateCorner.new("TeamStateCorner"))
	set_state(TeamStateAttack.new("TeamStateAttack"))
	set_state(TeamStateDefend.new("TeamStateDefend"))
