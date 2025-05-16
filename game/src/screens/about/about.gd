# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name About
extends Control

@onready var custom_tab_container: CustomTabContainer = %CustomTabContainer


func _ready() -> void:
	InputUtil.start_focus(self)

	custom_tab_container.setup([tr("Changelog"), tr("Contributors"), tr("Licenses")])


func _on_back_pressed() -> void:
	Main.previous_scene()

