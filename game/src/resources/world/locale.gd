# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Locale
extends Resource

var name: String
var code: String


func _init(
	p_name: String = "",
	p_code: String = "",
) -> void:
	name = p_name
	code = p_code
