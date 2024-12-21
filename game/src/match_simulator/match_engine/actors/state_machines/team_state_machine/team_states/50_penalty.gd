# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStatePenalty
extends StateMachineState


func execute() -> void:
	# if team has ball
		# move player to penalty spot
		# shoot
	change_to(TeamStateGoal.new())
	change_to(TeamStateCorner.new())
	change_to(TeamStateAttack.new())
	change_to(TeamStateDefend.new())
