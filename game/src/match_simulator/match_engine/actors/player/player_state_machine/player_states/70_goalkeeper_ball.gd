# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperBall")


func enter() -> void:
	owner.player.set_destination(owner.field.ball.pos)


func execute() -> void:
	if owner.player.destination_reached():
		set_state(PlayerStatePass.new())


func exit() -> void:
	owner.field.clock_running = true
