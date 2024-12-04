# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateGoal
extends StateMachineState



func update() -> void:
	# if team has ball
		# celebrate
	# else
		# players are sad
	change_to(TeamStateKickoff.new())
