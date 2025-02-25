# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control


func _ready() -> void:
	InputUtil.start_focus(self)


func _on_language_picker_language_change() -> void:
	Main.change_scene(Const.SCREEN_SETUP_THEME)
