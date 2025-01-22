# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateDefend
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateDefend")


func enter() -> void:
	# move players with no ball into positions
	for player: SimPlayer in owner.team.players:
		player.move_defense_pos()


func execute() -> void:
	if owner.team.has_ball:
		set_state(TeamStateAttack.new())
		return
	
	if owner.field.clock_running:
		owner.team.player_chase(owner.team.player_nearest_to_ball())

