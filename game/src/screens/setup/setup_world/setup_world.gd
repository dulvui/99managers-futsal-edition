# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

const DEFAULT_SEED: String = "289636-522140-666834"

var generation_seed: String = DEFAULT_SEED

# manager
@onready var nations: OptionButton = %Nationality
@onready var manager_name: LineEdit = %Name
@onready var manager_surname: LineEdit = %Surname
# game settings
@onready var player_names_option: OptionButton = %PlayerNames
@onready var start_year_spinbox: SpinBox = %StartYear
@onready var generation_seed_edit: LineEdit = %GeneratedSeedLineEdit

@onready var continue_button: Button = %Continue


func _ready() -> void:
	InputUtil.start_focus(self)
	
	for player_name: Enum.PlayerNames in Enum.PlayerNames.values():
		player_names_option.add_item(Enum.get_player_names_text(player_name))

	generation_seed_edit.text = generation_seed
	# set start year to current system year
	start_year_spinbox.value = Time.get_date_dict_from_system().year

	# reset temp values
	if Global.manager:
		manager_name.text = Global.manager.name
		manager_surname.text = Global.manager.surname
	
	var nation_names: NationNames = NationNames.new()

	for nation: String in nation_names.get_all_nations():
		nations.add_item(nation)

	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0


func _on_generated_seed_line_edit_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		generation_seed = new_text


func _on_genearate_seed_button_pressed() -> void:
	generation_seed = RngUtil.uuid()
	generation_seed_edit.text = generation_seed


func _on_default_seed_button_pressed() -> void:
	generation_seed = DEFAULT_SEED
	generation_seed_edit.text = generation_seed


func _on_continue_pressed() -> void:

	# setup manager
	if manager_name.text.length() * manager_surname.text.length() == 0:
		return

	var manager: Manager = Manager.new()
	manager.name = manager_name.text
	manager.surname = manager_surname.text
	manager.nation = nations.get_item_text(nations.selected)
	Global.manager = manager

	IdUtil.reset()

	# setup generation
	if generation_seed.length() == 0:
		generation_seed = DEFAULT_SEED

	# start date in fomrat YYYY-MM-DDTHH:MM:SS
	var start_year: int = int(start_year_spinbox.value)
	var start_date_str: String = (
		"%d-%02d-%02dT00:00:00" % [start_year, Const.SEASON_START_MONTH, Const.SEASON_START_DAY]
	)
	Global.start_date = Time.get_datetime_dict_from_datetime_string(
		start_date_str, true
	)
	# also set Global.start_date, so functions like person.get_age work
	Global.generation_seed = generation_seed
	Global.generation_player_names = player_names_option.selected as Enum.PlayerNames

	RngUtil.reset_seed(generation_seed, player_names_option.selected)

	LoadingUtil.start(tr("Generating players"), LoadingUtil.Type.GENERATION, true)
	Main.show_loading_screen(Const.SCREEN_SETUP_TEAM)
	ThreadUtil.generate_players()


func _on_name_text_changed(_new_text: String) -> void:
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0


func _on_surame_text_changed(_new_text: String) -> void:
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0


func _on_back_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)

