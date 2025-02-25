# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultOptionButton
extends OptionButton


func _ready() -> void:
	var height: int = int(get_viewport_rect().size.y / 3)
	var width: int = int(get_viewport_rect().size.y / 3)

	get_popup().max_size = Vector2(width, height)
