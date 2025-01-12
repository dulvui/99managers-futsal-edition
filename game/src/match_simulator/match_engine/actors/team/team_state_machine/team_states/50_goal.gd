# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateGoal
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateGoal")


func execute() -> void:
	# if team has ball
		# celebrate
	# else
		# players are sad
	set_state(TeamStateKickoff.new())
