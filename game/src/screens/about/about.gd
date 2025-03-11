# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name About
extends PanelContainer


func _ready() -> void:
	InputUtil.start_focus(self)


func _on_back_pressed() -> void:
	Main.previous_scene()
