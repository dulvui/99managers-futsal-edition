# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends TextureRect


func _ready() -> void:
	modulate = ThemeUtil.configuration.style_important_color
