# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Checksums
extends JSONResource

@export var list: Array[Checksum]


func _init(
	p_list: Array[Checksum],
) -> void:
	list = p_list

