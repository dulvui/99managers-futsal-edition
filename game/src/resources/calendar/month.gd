# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Month
extends Resource

var days: Array[Day]


func _init(
	p_days: Array[Day] = [],
) -> void:
	days = p_days

