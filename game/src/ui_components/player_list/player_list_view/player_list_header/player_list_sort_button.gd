
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListSortButton
extends Button

@export var sort_key: String


func _ready() -> void:
	if tooltip_text.is_empty() and text.length() > 1:
		tooltip_text = text


func _pressed() -> void:
	SoundUtil.play_button_sfx()
