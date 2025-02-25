# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Settings
extends Control

@onready var default_dialog: DefaultConfirmDialog = %DefaultDialog
@onready var general: GeneralSettings = %General
@onready var input: InputSettings = %Input


func _ready() -> void:
	InputUtil.start_focus(self)


func _on_defaults_pressed() -> void:
	default_dialog.popup_centered()


func _on_default_dialog_confirmed() -> void:
	general.restore_defaults()
	input.restore_defaults()
	ResUtil.save_config()


func _on_back_pressed() -> void:
	Main.previous_scene()
