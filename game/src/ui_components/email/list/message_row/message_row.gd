# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MessageRow
extends MarginContainer

var message: EmailMessage

@onready var subject_label: Label = %Subject
@onready var sender_label: Label = %Sender
@onready var date_label: Label = %Date
@onready var star: TextureButton = %Star
@onready var read_button: Button = %ReadButton


func setup(p_message: EmailMessage, index: int) -> void:
	message = p_message

	read_button.tooltip_text = tr("Click to read message")

	if index % 2 == 1:
		read_button.modulate = read_button.modulate.darkened(0.1)
		star.modulate = read_button.modulate.darkened(0.1)

	subject_label.set_text(message.subject)
	sender_label.set_text(message.sender)
	date_label.set_text(FormatUtil.day(message.date))

	star.button_pressed = message.starred
	_star_color()

	if not message.read:
		# make bold
		ThemeUtil.bold(subject_label)
		ThemeUtil.bold(sender_label)
		ThemeUtil.bold(date_label)


func _on_star_toggled(toggled_on: bool) -> void:
	message.starred = toggled_on
	_star_color()


func _on_read_button_pressed() -> void:
	ThemeUtil.remove_bold(subject_label)
	ThemeUtil.remove_bold(sender_label)
	ThemeUtil.remove_bold(date_label)


func _star_color() -> void:
	if star.button_pressed:
		star.modulate = ThemeUtil.configuration.style_important_color
	else:
		star.modulate = ThemeUtil.configuration.style_important_color.lightened(0.5)
