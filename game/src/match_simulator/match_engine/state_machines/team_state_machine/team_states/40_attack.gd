# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateAttack
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateAttack")


func enter() -> void:
	pass


func execute() -> void:
	if not owner.team.has_ball:
		set_state(TeamStateDefend.new())
	
	# move players with no ball into positions
	# set_state(TeamStateGoal.new())
	# set_state(TeamStateKickin.new())
	# set_state(TeamStateCorner.new())
	# set_state(TeamStateFreeKick.new())
	# set_state(TeamStatePenalty.new())
