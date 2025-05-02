# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SaveStates
extends JSONResource

@export var id_list: Array[String]
@export var active_id: String

var active: SaveState


func _init(
	p_id_list: Array[String] = [],
	p_active_id: String = "",
) -> void:
	id_list = p_id_list
	active_id = p_active_id


func new_save_state() -> void:
	var new_id: String = UUID.new_uuid()
	var new_state: SaveState = SaveState.new()
	new_state.id = new_id
	new_state.start_date = Global.start_date
	new_state.id_by_type = IdUtil.id_by_type
	new_state.current_season = 0
	new_state.generation_seed = Global.generation_seed
	new_state.generation_state = Global.generation_state
	new_state.generation_player_names = Global.generation_player_names

	new_state.initialize()

	# make active
	id_list.append(new_state.id)
	active_id = new_state.id
	active = new_state


func get_active() -> SaveState:
	if active != null:
		return active

	# load active
	if active == null and active_id != "":
		active = DataUtil.load_save_state(active_id)
		if active == null:
			print("error while loading save state with id %s, removing it" % active_id)
			id_list.erase(active_id)
			active_id = ""
		else:
			return active
	return null


func delete(state: SaveState) -> void:
	state.delete()
	id_list.erase(state.id)

	# set next value to active
	if id_list.size() > 0:
		active = DataUtil.load_save_state(id_list[-1])
		active_id = active.id
	else:
		active_id = ""
		active = null


# scan for new save states, that not exist in save_states.res yet
func scan() -> void:
	var dir: DirAccess = DirAccess.open(DataUtil.SAVE_STATES_PATH)
	if dir:
		dir.list_dir_begin()
		var file: String = dir.get_next()
		if dir.current_is_dir():
			if not file in id_list:
				print("new state id found %s" % file)
				id_list.append(file)

