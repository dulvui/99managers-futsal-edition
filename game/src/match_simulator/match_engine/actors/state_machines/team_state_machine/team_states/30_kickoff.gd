# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickoff
extends StateMachineState


func execute() -> void:
	# if team has ball
		# move player to center
		# pass to other player
	change_to(TeamStateAttack.new())
	# else
	change_to(TeamStateDefend.new())
