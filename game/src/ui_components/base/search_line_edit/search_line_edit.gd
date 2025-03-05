# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SearchLineEdit
extends HBoxContainer

signal text_changed(new_text: String)

@onready var line_edit: LineEdit = %LineEdit
@onready var shortcut: Button = %Shortcut


func _on_focus_entered() -> void:
	shortcut.hide()


func _on_focus_exited() -> void:
	shortcut.show()


func _on_shortcut_button_pressed() -> void:
	line_edit.grab_focus()


func _on_line_edit_text_changed(new_text:String) -> void:
	text_changed.emit(new_text)

