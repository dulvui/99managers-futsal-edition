# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperBall")


func enter() -> void:
	owner.player.set_destination(owner.field.ball.pos)


func execute() -> void:
	# if close to ball, chase it
	if owner.player.destination_reached():
		owner.field.clock_running = true
		set_state(PlayerStatePass.new())
		return

