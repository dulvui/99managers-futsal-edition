# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateKickin
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateKickin")


func execute() -> void:
	# if team has ball
		# move player to ball
		# pass to other player
	set_state(TeamStateAttack.new())
	# else
	set_state(TeamStateDefend.new())
