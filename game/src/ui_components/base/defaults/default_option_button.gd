# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name DefaultOptionButton
extends OptionButton


func _ready() -> void:
	get_popup().max_size = Vector2(400, 200)

