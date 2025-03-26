# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultConfirmDialog
extends PopupPanel

signal denied
signal confirmed

enum Type {
	YES_NO,
	YES_NO_CANCEL,
	ONLY_OK,
}

@export var custom_title: String = ""
@export_multiline var custom_text: String = ""
@export var type: Type = Type.YES_NO_CANCEL

@onready var rich_text_label: RichTextLabel = %Text
@onready var title_label: Label = %Title
@onready var cancel_button: Button = %Cancel
@onready var no_button: Button = %No
@onready var yes_button: Button = %Yes


func _ready() -> void:
	hide()

	# buttons
	if type == Type.YES_NO:
		cancel_button.hide()
	elif type == Type.ONLY_OK:
		cancel_button.text = tr("Ok")
		no_button.hide()
		yes_button.hide()
	
	# labels
	rich_text_label.text = custom_text
	title_label.text = custom_title


func append_text(text: String) -> void:
	rich_text_label.text += "\n" + text


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
