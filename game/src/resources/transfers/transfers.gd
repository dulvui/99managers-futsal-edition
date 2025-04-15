# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Transfers
extends JSONResource

@export var list: Array[Transfer]


func _init(
	p_list: Array[Transfer] = [],
) -> void:
	list = p_list

