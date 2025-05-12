# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name InputSettings
extends VBoxContainer

@onready var joypad_info: Label = %JoypadInfo
@onready var type_button: SwitchOptionButton = %TypeButton
@onready var automatic_detection_button: CheckButton = %AutomaticDetectionButton


func _ready() -> void:
	setup()


func setup() -> void:
	# joypad info
	JoypadUtil.joypad_changed.connect(
		func() -> void: joypad_info.text = JoypadUtil.get_joypad_type_string()
	)
	joypad_info.text = JoypadUtil.get_joypad_type_string()

	# type
	type_button.setup(Enum.input_type, Global.config.input_type)
	# detection mode
	automatic_detection_button.button_pressed = Global.config.input_automatic_detection


func restore_defaults() -> void:
	# type
	Global.config.input_type = 0 as Enum.InputType
	# detection mode
	Global.config.input_automatic_detection = true

	# reset values of all elements
	setup()


func _on_type_button_item_selected(index: int) -> void:
	InputUtil.type = index as Enum.InputType
	DataUtil.save_config()


func _on_automatic_detection_button_toggled(toggled_on: bool) -> void:
	Global.config.input_automatic_detection = toggled_on

	# enable/disable input type picker
	type_button.set_disabled(toggled_on)

	# set type if not set to automatic
	if not toggled_on:
		InputUtil.type = Global.config.input_type

	DataUtil.save_config()

