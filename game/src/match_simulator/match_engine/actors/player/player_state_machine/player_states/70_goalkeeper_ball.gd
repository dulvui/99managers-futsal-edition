# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperBall
extends PlayerStateMachineState

const WAIT: int = Const.STATE_UPDATE_TICKS * 3

var ticks: int


func _init() -> void:
	super("PlayerStateGoalkeeperBall")
	ticks = 0


func enter() -> void:
	owner.player.set_destination(owner.field.ball.pos)


func execute() -> void:
	if not owner.player.destination_reached():
		return
	
	ticks += 1
	if ticks < WAIT:
		return
	breakpoint
	
	set_state(PlayerStatePass.new())


func exit() -> void:
	owner.field.clock_running = true
