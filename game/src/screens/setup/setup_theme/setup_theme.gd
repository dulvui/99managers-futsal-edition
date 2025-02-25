# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control


func _on_default_button_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)

