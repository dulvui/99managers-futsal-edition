# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MouseCursor
extends Control

@onready var cursor_texture: TextureRect = $CursorTexture


func _process(_delta: float) -> void:
	cursor_texture.position = get_viewport().get_mouse_position()
