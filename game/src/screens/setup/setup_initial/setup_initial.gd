# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control


@onready var theme_picker: ThemePicker = %ThemePicker


func _ready() -> void:
	InputUtil.start_focus(self)
	theme_picker.themes.alignment = FlowContainer.ALIGNMENT_CENTER


func _on_continue_button_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)

