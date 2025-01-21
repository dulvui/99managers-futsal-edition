# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperBall", true)


func enter() -> void:
	owner.player.follow(owner.field.ball, 40)


func execute() -> void:
	# if close to ball, chase it
	if owner.player.destination_reached():
		owner.field.clock_running = true
		set_state(PlayerStatePass.new())
		return

