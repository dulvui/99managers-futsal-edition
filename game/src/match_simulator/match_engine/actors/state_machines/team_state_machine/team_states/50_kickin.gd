# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickin
extends StateMachineState


func execute() -> void:
	# if team has ball
		# move player to ball
		# pass to other player
	change_to(TeamStateAttack.new())
	# else
	change_to(TeamStateDefend.new())
