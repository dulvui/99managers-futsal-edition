# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultConfirmDialog
extends PopupPanel

signal denied
signal confirmed

@export var custom_title: String = ""
@export_multiline var custom_text: String = ""
@export var show_cancel: bool = false

@onready var rich_text_label: RichTextLabel = %Text
@onready var title_label: Label = %Title
@onready var cancel_button: Button = %Cancel
@onready var no_button: Button = %No


func _ready() -> void:
	hide()

	no_button.visible = show_cancel

	rich_text_label.text = custom_text
	title_label.text = custom_title


func _on_about_to_popup() -> void:
	InputUtil.start_focus(cancel_button)


func _on_cancel_pressed() -> void:
	hide()


func _on_no_pressed() -> void:
	hide()
	denied.emit()


func _on_yes_pressed() -> void:
	hide()
	confirmed.emit()


