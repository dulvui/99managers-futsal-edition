# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultButton
extends Button


func _on_pressed() -> void:
	SoundUtil.play_button_sfx()

