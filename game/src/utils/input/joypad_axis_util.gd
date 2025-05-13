# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

# workaround until not fixed https://github.com/godotengine/godot/issues/99331

# and in Tree analogical sticks also dont work correclty
# once this is fixes, ui left/right etc... can be readded on default input map

signal r2
signal l2

const THRESHOLD: float = 1

# ui events to map for joypad axis helper
var ui_left_event: InputEventAction
var ui_right_event: InputEventAction
var ui_up_event: InputEventAction
var ui_down_event: InputEventAction
var trigger_right_event: InputEventAction
var trigger_left_event: InputEventAction


func _ready() -> void:
	# setup axis helper events
	ui_left_event = InputEventAction.new()
	ui_left_event.action = "ui_left"
	ui_left_event.pressed = true

	ui_right_event = InputEventAction.new()
	ui_right_event.action = "ui_right"
	ui_right_event.pressed = true

	ui_up_event = InputEventAction.new()
	ui_up_event.action = "ui_up"
	ui_up_event.pressed = true

	ui_down_event = InputEventAction.new()
	ui_down_event.action = "ui_down"
	ui_down_event.pressed = true

	InputMap.add_action("L2")
	trigger_left_event = InputEventAction.new()
	trigger_left_event.action = "L2"
	trigger_left_event.pressed = true

	InputMap.add_action("R2")
	trigger_right_event = InputEventAction.new()
	trigger_right_event.action = "R2"
	trigger_right_event.pressed = false


func handle_event(event: InputEvent) -> void:
	if not event is InputEventJoypadMotion:
		return

	var motion_event: InputEventJoypadMotion = event as InputEventJoypadMotion

	match motion_event.axis:
		JOY_AXIS_TRIGGER_LEFT:
			if motion_event.axis_value >= THRESHOLD:
				l2.emit()
				Input.parse_input_event(trigger_left_event)
		JOY_AXIS_TRIGGER_RIGHT:
			if motion_event.axis_value >= THRESHOLD:
				r2.emit()
				Input.parse_input_event(trigger_right_event)
		JOY_AXIS_LEFT_X, JOY_AXIS_RIGHT_X:
			if motion_event.axis_value <= -THRESHOLD:
				Input.parse_input_event(ui_left_event)
			elif motion_event.axis_value >= THRESHOLD:
				Input.parse_input_event(ui_right_event)
		JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y:
			if motion_event.axis_value <= -THRESHOLD:
				Input.parse_input_event(ui_up_event)
			elif motion_event.axis_value >= THRESHOLD:
				Input.parse_input_event(ui_down_event)

