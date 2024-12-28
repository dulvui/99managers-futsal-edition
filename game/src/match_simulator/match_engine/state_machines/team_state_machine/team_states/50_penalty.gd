# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStatePenalty
extends TeamStateMachineState


func _init() -> void:
	super("TeamStatePenalty")


func execute() -> void:
	# if team has ball
		# move player to penalty spot
		# shoot
	set_state(TeamStateGoal.new())
	set_state(TeamStateCorner.new())
	set_state(TeamStateAttack.new())
	set_state(TeamStateDefend.new())
