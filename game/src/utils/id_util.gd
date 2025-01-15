# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum Types {
	THEME,
	COMPETITION,
	TEAM,
	PERSON,
	TRANSFER,
	EMAIL,
	MATCH,
	POSITION_VARIATION,
}


# max int value is 9223372036854775807, so quite safe to use
func next_id(type: Types) -> int:
	var state: SaveState = Global.save_states.get_active()

	var type_key: String = Types.keys()[type]
	if type_key not in state.id_by_type:
		state.id_by_type[type_key] = 0
	state.id_by_type[type_key] += 1
	return state.id_by_type[type_key]
