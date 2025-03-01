# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name InputSettings
extends VBoxContainer

@onready var joypad_info: Label = %JoypadInfo
@onready var type_button: SwitchOptionButton = %TypeButton
@onready var detection_mode_button: SwitchOptionButton = %DetectionModeButton


func _ready() -> void:
	# joypad info
	JoypadUtil.joypad_changed.connect(
		func() -> void: joypad_info.text = JoypadUtil.get_joypad_type_string()
	)
	joypad_info.text = JoypadUtil.get_joypad_type_string()

	# type
	type_button.setup(Enum.input_type, Global.config.input_type)
	# detection mode
	detection_mode_button.setup(Enum.input_detection_mode, Global.config.input_detection_mode)


func restore_defaults() -> void:
	# type
	Global.config.input_type = 0 as Enum.InputType
	type_button.option_button.selected = 0
	# detection mode
	Global.config.input_detection_mode = 0 as Enum.InputDetectionMode
	detection_mode_button.option_button.selected = 0


func _on_detection_mode_button_item_selected(index: int) -> void:
	Global.config.input_detection_mode = index as Enum.InputDetectionMode
	if index == Enum.InputDetectionMode.MANUAL:
		InputUtil.type = Global.config.input_type
	ResUtil.save_config()


func _on_type_button_item_selected(index: int) -> void:
	InputUtil.type = index as Enum.InputType
	ResUtil.save_config()
