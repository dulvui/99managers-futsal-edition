# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEvents
extends MarginContainer

@onready var list: VBoxContainer = %List


func append_text(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	list.add_child(label)
