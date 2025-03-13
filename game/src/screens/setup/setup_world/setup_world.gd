# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

const DEFAULT_SEED: StringName = "289636-522140-666834"
const CONTINUE_DISABLED_TOOLTIP: StringName = "Name and surname missing"

var generation_seed: String = DEFAULT_SEED
var custom_file_path: String

# manager
@onready var nations: OptionButton = %Nationality
@onready var manager_name: LineEdit = %Name
@onready var manager_surname: LineEdit = %Surname
# game settings
@onready var player_names_option: OptionButton = %PlayerNames
@onready var start_year_spinbox: SpinBox = %StartYear
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
	Global.start_date = Time.get_datetime_dict_from_datetime_string(start_date_str, true)
	# also set Global.start_date, so functions like person.get_age work
	Global.generation_seed = generation_seed
	Global.generation_player_names = player_names_option.selected as Enum.PlayerNames

	RngUtil.reset_seed(generation_seed, player_names_option.selected)

	Main.manual_hide_loading_screen()
	# await and make sure loading screen is visible, befor it can be hidden on error
	await Main.show_loading_screen(tr("Generating teams and players"))
	Main.loaded.connect(_on_world_generated)

	Global.error_load_world = 0
	if default_file_button.button_pressed or custom_file_path.is_empty():
		ThreadUtil.generate_world()
	else:
		ThreadUtil.generate_world(custom_file_path)


func _on_name_text_changed(_new_text: String) -> void:
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0
	if continue_button.disabled:
		continue_button.tooltip_text = tr(CONTINUE_DISABLED_TOOLTIP)
	else:
		continue_button.tooltip_text = "" # NO_TRANSLATE


func _on_surame_text_changed(_new_text: String) -> void:
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0
	if continue_button.disabled:
		continue_button.tooltip_text = tr(CONTINUE_DISABLED_TOOLTIP)
	else:
		continue_button.tooltip_text = "" # NO_TRANSLATE


func _on_template_button_pressed() -> void:
	template_dialog.current_file = Generator.WORLD_CSV_PATH
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
		dir_access.copy(Generator.WORLD_CSV_PATH, path)
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


func _on_world_generated() -> void:
	# check world loading error
	if Global.error_load_world == 0:
		Main.change_scene(Const.SCREEN_SETUP_TEAM)
	else:
		# wait loading screen is hidden
		await Main.hide_loading_screen()
		file_error_dialog.popup_centered()


func _on_back_pressed() -> void:
	Main.change_scene(Const.SCREEN_MENU)
