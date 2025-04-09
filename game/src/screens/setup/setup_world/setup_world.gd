# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

const DEFAULT_SEED: StringName = "289636-522140-666834"
const CONTINUE_DISABLED_TOOLTIP: StringName = "Name and surname missing"

var generation_seed: String = DEFAULT_SEED
var custom_file_path: String
var start_year: String
var player_names: Enum.PlayerNames
var advanced_settings: bool

# manager
@onready var nations: SwitchOptionButton = %Nationality
@onready var manager_name: LineEdit = %Name
@onready var manager_surname: LineEdit = %Surname
# game settings
@onready var player_names_option: SwitchOptionButton = %PlayerNames
@onready var start_year_option: SwitchOptionButton = %StartYear

# advanced settings
@onready var advanced_settings_box: VBoxContainer = %AdvancedSettings
@onready var generation_seed_edit: LineEdit = %GeneratedSeedLineEdit
@onready var file_dialog: FileDialog = %FileDialog
@onready var file_info_dialog: DefaultConfirmDialog = %FileInfoDialog
@onready var file_error_dialog: DefaultConfirmDialog = %FileErrorDialog
@onready var template_dialog: FileDialog = %TemplateDialog
@onready var file_path_line_edit: LineEdit = %FilePathLineEdit
@onready var default_file_button: CheckButton = %DefaultFileButton

@onready var continue_button: Button = %Continue


func _ready() -> void:
	InputUtil.start_focus(self)

	Main.loaded.connect(_on_world_generated)
	
	# setup ui components
	advanced_settings_box.hide()
	advanced_settings = false

	generation_seed_edit.text = generation_seed

	player_names = Enum.PlayerNames.values()[0]
	player_names_option.setup(Enum.player_names)

	# create world to get nations
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()
	nations.option_button.add_item(tr("Your nationality"))
	var all_nations: Array[String] = []
	for nation: Nation in world.get_all_nations(true):
		all_nations.append(tr(nation.name))
	for nation: String in all_nations:
		nations.option_button.add_item(nation)

	start_year = str(Time.get_date_dict_from_system().year)
	var years: Array[String] = []
	for year: int in range(2000, 3000):
		years.append(str(year))
	start_year_option.setup(years, years.find(start_year))

	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0

	file_path_line_edit.text = tr("Default file")

	# set filters here to prevent adding "*.csv" to game.pot file
	file_dialog.filters[0] = "*.csv"
	template_dialog.filters[0] = "*.csv"


func _on_generated_seed_line_edit_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		generation_seed = new_text


func _on_genearate_seed_button_pressed() -> void:
	generation_seed = RngUtil.uuid()
	generation_seed_edit.text = generation_seed


func _on_default_seed_button_pressed() -> void:
	generation_seed = DEFAULT_SEED
	generation_seed_edit.text = generation_seed


func _on_name_text_changed(_new_text: String) -> void:
	continue_button.disabled = not _is_valid()
	if continue_button.disabled:
		continue_button.tooltip_text = tr(CONTINUE_DISABLED_TOOLTIP)
	else:
		continue_button.tooltip_text = "" # NO_TRANSLATE


func _on_surame_text_changed(_new_text: String) -> void:
	continue_button.disabled = not _is_valid()
	if continue_button.disabled:
		continue_button.tooltip_text = tr(CONTINUE_DISABLED_TOOLTIP)
	else:
		continue_button.tooltip_text = "" # NO_TRANSLATE


func _on_nationality_item_selected(_index: int) -> void:
	continue_button.disabled = not _is_valid()


func _on_player_names_item_selected(index: int) -> void:
	player_names = Enum.PlayerNames.values()[index]


func _on_start_year_item_selected(index: int) -> void:
	start_year = start_year_option.option_button.get_item_text(index)


func _is_valid() -> bool:
	if manager_name.text.length() == 0:
		return false
	if manager_surname.text.length() == 0:
		return false
	if nations.option_button.selected == 0:
		return false
	return true


func _on_template_button_pressed() -> void:
	template_dialog.current_file = "99managers-futsal-data.csv"
	template_dialog.popup_centered()


func _on_file_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	custom_file_path = path
	default_file_button.button_pressed = false
	file_path_line_edit.text = custom_file_path


func _on_template_dialog_file_selected(path: String) -> void:
	var dir_access: DirAccess = DirAccess.open(path.get_base_dir())
	if dir_access:
		dir_access.copy(Const.WORLD_CSV_PATH_WITH_PLAYERS, path)
		print("creating backup for %s done." % path)
	else:
		print("creating backup for %s gone wrong." % path)


func _on_default_file_button_toggled(toggled_on: bool) -> void:
	SoundUtil.play_button_sfx()

	if toggled_on or custom_file_path.is_empty():
		file_path_line_edit.text = tr("Default file")
	else:
		file_path_line_edit.text = custom_file_path


func _on_files_more_info_pressed() -> void:
	file_info_dialog.popup_centered()


func _on_advanced_stettings_button_toggled(toggled_on: bool) -> void:
	advanced_settings = toggled_on
	advanced_settings_box.visible = toggled_on


func _on_continue_pressed() -> void:
	# setup manager
	if not _is_valid():
		return

	var manager: Manager = Manager.new()
	manager.name = manager_name.text
	manager.surname = manager_surname.text
	manager.nation = nations.option_button.get_item_text(nations.option_button.selected)
	Global.manager = manager

	IdUtil.reset()

	# setup generation
	if generation_seed.length() == 0:
		generation_seed = DEFAULT_SEED

	# start date in format YYYY-MM-DDTHH:MM:SS
	var start_date_str: String = (
		"%s-%02d-%02dT00:00:00" % [start_year, Const.SEASON_START_MONTH, Const.SEASON_START_DAY]
	)
	Global.start_date = Time.get_datetime_dict_from_datetime_string(start_date_str, true)
	# also set Global.start_date, so functions like person.get_age work
	Global.generation_seed = DEFAULT_SEED
	Global.generation_player_names = player_names

	if advanced_settings:
		Global.generation_seed = generation_seed

	RngUtil.reset_seed(generation_seed, player_names_option.option_button.selected)

	Main.manual_hide_loading_screen()
	# await and make sure loading screen is visible, before it can be hidden on error
	await Main.show_loading_screen(tr("Generating teams and players"))

	if not advanced_settings or default_file_button.button_pressed or custom_file_path.is_empty():
		ThreadUtil.generate_world()
	else:
		ThreadUtil._generate_world(custom_file_path)


func _on_world_generated() -> void:
	# check world loading error
	if Global.generation_errors.size() == 0:
		Main.change_scene(Const.SCREEN_SETUP_TEAM, true)
	else:
		# wait loading screen is hidden
		await Main.hide_loading_screen()
		# add errors
		file_error_dialog.append_text(tr("Errors"))
		for error: Enum.GenerationError in Global.generation_errors:
			file_error_dialog.append_text(Enum.get_generation_error_text(error))
		# add warnings
		file_error_dialog.append_text(tr("Warnings"))
		for warning: Enum.GenerationWarning in Global.generation_warnings:
			file_error_dialog.append_text(Enum.get_generation_warning_text(warning))
			
		file_error_dialog.popup_centered()


func _on_back_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)


