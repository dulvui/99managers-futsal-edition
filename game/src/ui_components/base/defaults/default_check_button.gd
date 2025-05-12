# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultCheckButton
extends CheckButton


func _pressed() -> void:
	SoundUtil.play_button_sfx()

