# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

const MAX: int = 9223372036854775807

enum Types {
	COMPETITION,
	TEAM,
	PERSON,
	OFFER,
	EMAIL,
	MATCH,
}

var id_by_type: Dictionary


func reset() -> void:
	id_by_type = {}


# max int value is 9223372036854775807, so quite safe to use
func next_id(type: Types) -> int:
	var type_key: String = Types.keys()[type]

	if not id_by_type.has(type_key):
		id_by_type[type_key] = 0

	if id_by_type[type_key] == MAX:
		print("id util max reached for %s. restrarting from 0" % type_key)
		id_by_type[type_key] = 0

	id_by_type[type_key] += 1
	return id_by_type[type_key]

