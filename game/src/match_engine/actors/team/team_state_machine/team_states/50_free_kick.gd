# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateFreeKick
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateFreeKick")


func execute() -> void:
	pass
	# if team has ball
	# move player to free kick
	# shoot
	# else
	# some players make wall
