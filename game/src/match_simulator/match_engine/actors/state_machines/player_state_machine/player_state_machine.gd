# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateMachine
extends StateMachine


func _init() -> void:
	super(PlayerStateEnterField.new())


func update() -> void:
	pass
