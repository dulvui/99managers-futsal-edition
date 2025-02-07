# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

#TODO
# - random name button

extends Control

const DEFAULT_SEED: String = "289636-522140-666834"

var generation_seed: String = DEFAULT_SEED

@onready var player_names_option: OptionButton = %PlayerNames
@onready var start_year_spinbox: SpinBox = %StartYear
@onready var generation_seed_edit: LineEdit = %GeneratedSeedLineEdit


func _ready() -> void:
	InputUtil.start_focus(self)
	
	Global.save_states.new_temp_state()

	for player_name: String in Const.PlayerNames:
		player_names_option.add_item(player_name)

	generation_seed_edit.text = generation_seed
	# set start year to current system year
	start_year_spinbox.get_line_edit().text = str(Time.get_datetime_dict_from_system().year)


func _on_generated_seed_line_edit_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		generation_seed = new_text


func _on_genearate_seed_button_pressed() -> void:
	generation_seed = RngUtil.uuid()
	generation_seed_edit.text = generation_seed


func _on_default_seed_button_pressed() -> void:
	generation_seed = DEFAULT_SEED
	generation_seed_edit.text = generation_seed


func _on_back_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)


func _on_continue_pressed() -> void:
	if generation_seed.length() == 0:
		generation_seed = DEFAULT_SEED

	# start date in fomrat YYYY-MM-DDTHH:MM:SS
	var start_year: String = start_year_spinbox.get_line_edit().text
	var start_date_str: String = (
		"%s-%02d-%02dT00:00:00" % [start_year, Const.SEASON_START_MONTH, Const.SEASON_START_DAY]
	)
	Global.save_states.temp_state.start_date = Time.get_datetime_dict_from_datetime_string(
		start_date_str, true
	)
	# also set Global.start_date, so functions like person.get_age work
	Global.start_date = Global.save_states.temp_state.start_date
	Global.save_states.temp_state.generation_seed = generation_seed
	Global.save_states.temp_state.generation_player_names = player_names_option.selected as Const.PlayerNames

	RngUtil.reset_seed(generation_seed, player_names_option.selected)

	LoadingUtil.start(tr("GENERATING_PLAYERS"), LoadingUtil.Type.GENERATION, true)
	Main.show_loading_screen(Const.SCREEN_SETUP_MANAGER)
	ThreadUtil.generate_world()

