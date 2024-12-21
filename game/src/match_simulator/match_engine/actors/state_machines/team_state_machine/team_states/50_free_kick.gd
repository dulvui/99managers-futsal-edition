# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateFreeKick
extends StateMachineState
	

func execute() -> void:
	# if team has ball
		# move player to free kick
		# shoot
	# else
		# some players make wall
	change_to(TeamStateGoal.new())
	change_to(TeamStateCorner.new())
	change_to(TeamStateAttack.new())
	change_to(TeamStateDefend.new())
