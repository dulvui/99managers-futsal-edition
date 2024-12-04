# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateCorner
extends StateMachineState


func update() -> void:
	# if team has ball
		# move player to corner position
		# pass/cross
	# else
		# mark players
	change_to(TeamStateAttack.new())
	change_to(TeamStateDefend.new())
