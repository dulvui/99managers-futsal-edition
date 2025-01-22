# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SaveState
extends JSONResource


@export var id: String
@export var config_version: String
@export var config_version_history: Dictionary
@export var start_date: Dictionary
@export var generation_seed: String
@export var generation_state: int
@export var generation_player_names: Const.PlayerNames
@export var current_season: int
@export var match_speed: MatchScreen.Speed
@export var id_by_type: Dictionary
# metadata, only used for state entry
@export var meta_team_name: String
@export var meta_manager_name: String
@export var meta_team_position: String
@export var meta_last_save: Dictionary
@export var meta_game_date: Dictionary
@export var meta_create_date: Dictionary
@export var meta_is_temp: bool


func _init(
	p_generation_seed: String = "SuchDefaultSeed",
	p_generation_state: int = 0,
	p_generation_player_names: Const.PlayerNames = Const.PlayerNames.MALE,
	p_current_season: int = 0,
	p_match_speed: MatchScreen.Speed = MatchScreen.Speed.KEY_ACTIONS,
	p_id: String = "",
	p_id_by_type: Dictionary = {},
	p_config_version: String = Global.config_version,
	p_start_date: Dictionary = Time.get_datetime_dict_from_system(),
	p_meta_team_name: String = "",
	p_meta_manager_name: String = "",
	p_meta_team_position: String = "",
	p_meta_last_save: Dictionary = {},
	p_meta_game_date: Dictionary = {},
	p_meta_is_temp: bool = true,
) -> void:
	id = p_id
	config_version = p_config_version
	start_date = p_start_date
	generation_seed = p_generation_seed
	generation_state = p_generation_state
	generation_player_names = p_generation_player_names
	current_season = p_current_season
	match_speed = p_match_speed
	id_by_type = p_id_by_type
	meta_team_name = p_meta_team_name
	meta_manager_name = p_meta_manager_name
	meta_team_position = p_meta_team_position
	meta_last_save = p_meta_last_save
	meta_game_date = p_meta_game_date
	meta_is_temp = p_meta_is_temp


func initialize() -> void:
	_create_dir()
	# save static metadata
	meta_team_name = Global.team.name
	meta_manager_name = Global.manager.get_full_name()
	meta_create_date = Time.get_datetime_dict_from_system()
	meta_team_position = (str(Global.league.table().get_position()) + ". " + Global.league.name)
	meta_last_save = Time.get_datetime_dict_from_system()
	meta_game_date = Global.world.calendar.date


func delete() -> void:
	var user_dir: DirAccess = DirAccess.open(Const.SAVE_STATES_PATH)
	if user_dir:
		var err: int = user_dir.change_dir(id)
		if err == OK:
			# remove all files
			var file_name: String = user_dir.get_next()
			while file_name != "":
				OS.move_to_trash(ProjectSettings.globalize_path(Const.SAVE_STATES_PATH + id + "/" + file_name))
				file_name = user_dir.get_next()
		# delete folder
		err = user_dir.change_dir(Const.SAVE_STATES_PATH)
		if err == OK and user_dir.dir_exists(id):
			OS.move_to_trash(ProjectSettings.globalize_path(Const.SAVE_STATES_PATH + id))


func _create_dir() -> void:
	# create id directory, if not exist yet
	var save_state_dir: DirAccess = DirAccess.open(Const.SAVE_STATES_PATH)
	if save_state_dir and not save_state_dir.dir_exists(id):
		var err: int = save_state_dir.make_dir(id)
		if err != OK:
			print("error while creating save state dir")


