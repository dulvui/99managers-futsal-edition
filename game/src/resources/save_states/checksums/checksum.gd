# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Checksum
extends JSONResource


@export var unix_timestamp: int
@export var sha256: String
@export var path: String


func _init(
	p_path: String = "",
	p_unix_timestamp: int = 0,
	p_sha256: String = "",
) -> void:
	path = p_path
	unix_timestamp = p_unix_timestamp
	sha256 = p_sha256

